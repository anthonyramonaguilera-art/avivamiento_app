// lib/screens/feed/create_post_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/posts_provider.dart';
import 'package:avivamiento_app/utils/constants.dart';

enum MediaType { none, image, video, audio }

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  MediaType _selectedMediaType = MediaType.none;
  XFile? _selectedImageFile;
  XFile? _selectedVideoFile;
  XFile? _selectedAudioFile;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _canUploadVideo() {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return false;
    return user.rol == AppConstants.rolePastor ||
        user.rol == AppConstants.roleLider ||
        user.rol == AppConstants.roleAdmin;
  }

  bool _canUploadAudio() {
    final user = ref.read(userProfileProvider).value;
    if (user == null) return false;
    return user.rol == AppConstants.rolePastor ||
        user.rol == AppConstants.roleLider ||
        user.rol == AppConstants.roleAdmin ||
        user.rol == AppConstants.roleMusico;
  }

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMediaType = MediaType.image;
          _selectedImageFile = pickedFile;
          _selectedVideoFile = null;
          _selectedAudioFile = null;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _pickVideo() async {
    if (!_canUploadVideo()) {
      _showError('No tienes permisos para subir videos');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Verificar límite de 50MB
        if (fileSize > 52428800) {
          _showError('El video no puede superar 50MB');
          return;
        }

        setState(() {
          _selectedMediaType = MediaType.video;
          _selectedVideoFile = XFile(result.files.single.path!);
          _selectedImageFile = null;
          _selectedAudioFile = null;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar video: $e');
    }
  }

  Future<void> _pickAudio() async {
    if (!_canUploadAudio()) {
      _showError('No tienes permisos para subir audio');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Verificar límite de 10MB
        if (fileSize > 10485760) {
          _showError('El audio no puede superar 10MB');
          return;
        }

        setState(() {
          _selectedMediaType = MediaType.audio;
          _selectedAudioFile = XFile(result.files.single.path!);
          _selectedImageFile = null;
          _selectedVideoFile = null;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar audio: $e');
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedMediaType = MediaType.none;
      _selectedImageFile = null;
      _selectedVideoFile = null;
      _selectedAudioFile = null;
    });
  }

  Future<void> _submitPost() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      _showError('Error: No estás identificado. Reinicia la app.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final postService = ref.read(postServiceProvider);

      await postService.createPost(
        content: _textController.text.trim(),
        authorId: user.id,
        authorName: user.nombre,
        authorPhotoUrl: user.fotoUrl,
        authorRole: user.rol,
        imageFile: _selectedImageFile,
        videoFile: _selectedVideoFile,
        audioFile: _selectedAudioFile,
      );

      // Refrescar el feed
      await ref.read(postsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación creada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("❌ Error UI: $e");
      _showError('Error al publicar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaTypeIcon = {
      MediaType.image: Icons.image,
      MediaType.video: Icons.videocam,
      MediaType.audio: Icons.audiotrack,
    };

    final mediaTypeLabel = {
      MediaType.image: 'Imagen',
      MediaType.video: 'Video',
      MediaType.audio: 'Audio',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitPost,
              tooltip: "Publicar",
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Input de texto
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Comparte una palabra de bendición...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLines: null,
                      style: const TextStyle(fontSize: 16),
                      validator: (value) => value!.trim().isEmpty
                          ? 'Escribe algo para publicar'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Vista previa de medios
                    if (_selectedMediaType != MediaType.none) ...[
                      _buildMediaPreview(
                        mediaTypeIcon[_selectedMediaType]!,
                        mediaTypeLabel[_selectedMediaType]!,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Barra de progreso
                    if (_isLoading && _uploadProgress > 0)
                      Column(
                        children: [
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 8),
                          Text(
                            'Subiendo... ${(_uploadProgress * 100).toInt()}%',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Botones inferiores de media
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    _MediaButton(
                      icon: Icons.image,
                      label: 'Foto',
                      color: Colors.green,
                      onPressed: _isLoading ? null : _pickImage,
                    ),
                    if (_canUploadVideo()) ...[
                      const SizedBox(width: 8),
                      _MediaButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        color: Colors.red,
                        onPressed: _isLoading ? null : _pickVideo,
                      ),
                    ],
                    if (_canUploadAudio()) ...[
                      const SizedBox(width: 8),
                      _MediaButton(
                        icon: Icons.audiotrack,
                        label: 'Audio',
                        color: Colors.purple,
                        onPressed: _isLoading ? null : _pickAudio,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFileName(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _clearMedia,
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    if (_selectedImageFile != null) {
      return _selectedImageFile!.name;
    } else if (_selectedVideoFile != null) {
      return _selectedVideoFile!.name;
    } else if (_selectedAudioFile != null) {
      return _selectedAudioFile!.name;
    }
    return '';
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: onPressed != null ? color.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: onPressed != null ? color : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: onPressed != null ? color : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
