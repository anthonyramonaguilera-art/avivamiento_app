// lib/screens/feed/create_post_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
// IMPORT AÑADIDO: servicio de subida temporalmente usado desde esta pantalla
// Importamos explícitamente solo `UploadService` para evitar ambigüedades
import 'package:avivamiento_app/services/upload_service.dart'
    show UploadService;

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
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    }
  }

  // ignore: unused_element
  Future<void> _submitPost() async {
    // 1. Validar el formulario
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. Comprobar que no se esté procesando ya una petición
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final user = ref.read(userProfileProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Debes estar autenticado para publicar.')),
      );
      setState(
          () => _isLoading = false); // [CORRECCIÓN] Resetea el estado si falla
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
      );

      // [CORRECCIÓN] La navegación solo ocurre si todo sale bien.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación creada con éxito')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la publicación: $e')),
        );
      }
    } finally {
      // 3. [CORRECCIÓN] Aseguramos que el estado de carga se resetee siempre.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Publicación'),
        actions: [
          // [MODIFICADO] Mostramos un indicador de carga o el botón.
          // El estado _isLoading ahora controla correctamente la UI.
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              // MODIFICACIÓN TEMPORAL: en lugar de crear la publicación,
              // aquí solo probamos el servicio de subida que implementaste.
              // Esto evita lógica adicional y facilita validar la subida.
              onPressed: _isLoading
                  ? null
                  : () async {
                      // Si no hay imagen seleccionada no hacemos nada
                      if (_selectedImageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Selecciona una imagen primero')),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        // Usamos el servicio directamente. Nota: UploadService
                        // debe manejar errores internamente y lanzar si ocurre.
                        // Convertimos XFile -> File antes de subir
                        final file = File(_selectedImageFile!.path);
                        // Llamamos directamente al constructor de la clase exportada
                        final key = await UploadService().uploadImageToS3(file);
                        // Mostramos el resultado en consola (temporal)
                        // y en un SnackBar para visibilidad rápida.
                        // ignore: avoid_print
                        print('RESULTADO FINAL DE LA SUBIDA: $key');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Upload key: ${key ?? 'null'}')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error subiendo imagen: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '¿Qué estás pensando?',
                  border: InputBorder.none,
                ),
                maxLines: null,
                validator: (value) => value!.trim().isEmpty
                    ? 'El contenido no puede estar vacío'
                    : null,
              ),
              const SizedBox(height: 20),
              if (_selectedImageFile != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Añadir Imagen'),
          onPressed: _isLoading
              ? null
              : _pickImage, // Deshabilita el botón mientras se carga
        ),
      ),
    );
  }
}
