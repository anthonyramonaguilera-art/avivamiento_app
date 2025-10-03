// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  /// Abre la galería, permite al usuario seleccionar una imagen,
  /// la sube al servicio y actualiza el perfil del usuario.
  Future<void> _pickAndUploadImage(UserModel user) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Comprime un poco la imagen para ahorrar datos
    );

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userService = ref.read(userServiceProvider);

        // 1. Sube la imagen a ImgBB
        final downloadUrl = await userService.uploadProfilePictureToImgbb(
          pickedFile,
        );

        // 2. Actualiza el perfil del usuario con la nueva URL
        await userService.updateUserProfile(uid: user.id, fotoUrl: downloadUrl);

        // 3. Invalida el provider para forzar la recarga inmediata de la foto
        ref.invalidate(userProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada con éxito'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Muestra un cuadro de diálogo para que el usuario edite su nombre.
  Future<void> _showEditNameDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.nombre);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Nombre'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Nuevo nombre"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final newName = nameController.text.trim();
                // Cerramos el diálogo primero para una mejor experiencia de usuario.
                Navigator.of(context).pop();

                if (newName.isNotEmpty && newName != user.nombre) {
                  try {
                    final userService = ref.read(userServiceProvider);
                    await userService.updateUserProfile(
                      uid: user.id,
                      nombre: newName,
                    );

                    // Forzamos la actualización de los datos del usuario en la UI.
                    ref.invalidate(userProfileProvider);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nombre actualizado con éxito'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar el nombre: $e'),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: userProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Debes iniciar sesión para ver tu perfil.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                            ? NetworkImage(user.fotoUrl!)
                            : null,
                        child: user.fotoUrl == null || user.fotoUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _pickAndUploadImage(user),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Nombre: ${user.nombre}',
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () => _showEditNameDialog(user),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${user.email}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rol: ${user.rol}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    ref.read(authServiceProvider).signOut();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
