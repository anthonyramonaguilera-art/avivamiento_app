// lib/screens/feed/create_post_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// Importamos los providers y servicios correctos
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  XFile? _selectedImageFile;

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isLoading) return;

    // Ocultar teclado
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Obtener datos del usuario actual
    final user = ref.read(userProfileProvider).value;

    // Validación de seguridad: Usuario debe existir
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: No estás identificado. Reinicia la app.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Llamamos al PostService (que ya conectamos a AWS)
      final postService = ref.read(postServiceProvider);

      await postService.createPost(
        content: _textController.text.trim(),
        authorId: user.id, // "USER#..."
        authorName: user.nombre,
        authorPhotoUrl: user.fotoUrl,
        authorRole: user.rol,
        imageFile:
            _selectedImageFile, // Pasamos el XFile, el servicio lo convertirá
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación creada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volver al Feed
      }
    } catch (e) {
      print("❌ Error UI: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitPost, // Llamamos a la función REAL
              tooltip: "Publicar",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input de Texto
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'comparte una palabra de bendición...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                validator: (value) =>
                    value!.trim().isEmpty ? 'Escribe algo para publicar' : null,
              ),
              const SizedBox(height: 20),

              // Previsualización de Imagen
              if (_selectedImageFile != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_selectedImageFile!.path)
                              : FileImage(File(_selectedImageFile!.path))
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedImageFile = null;
                        });
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      // Botón flotante para adjuntar foto
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImage,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
