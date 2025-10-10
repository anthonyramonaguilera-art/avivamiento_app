// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/screens/admin/admin_panel_screen.dart'; // [NUEVO] Importamos el panel
import 'package:avivamiento_app/utils/constants.dart'; // [NUEVO] Importamos constantes

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;

  Future<void> _pickAndUploadImage(UserModel user) async {
    // ... (este método no cambia)
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final userService = ref.read(userServiceProvider);
        final downloadUrl = await userService.uploadProfilePictureToImgbb(pickedFile);
        await userService.updateUserProfile(uid: user.id, fotoUrl: downloadUrl);
        ref.invalidate(userProfileProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil actualizada')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEditNameDialog(UserModel user) async {
    // ... (este método no cambia)
    final nameController = TextEditingController(text: user.nombre);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Nombre'),
          content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Nuevo nombre"), autofocus: true),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                Navigator.of(context).pop();
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != user.nombre) {
                  try {
                    await ref.read(userServiceProvider).updateUserProfile(uid: user.id, nombre: newName);
                    ref.invalidate(userProfileProvider);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el nombre: $e')));
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
            return const Center(child: Text('Debes iniciar sesión para ver tu perfil.'));
          }

          // [CAMBIO] Usamos las constantes para verificar el permiso
          final bool canAccessPanel = [AppConstants.rolePastor, AppConstants.roleAdmin].contains(user.rol);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (El widget del Avatar y la información del perfil no cambian)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user.fotoUrl != null && user.fotoUrl!.isNotEmpty ? NetworkImage(user.fotoUrl!) : null,
                        child: user.fotoUrl == null || user.fotoUrl!.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                      ),
                      Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 22, backgroundColor: Colors.white, child: CircleAvatar(radius: 20, backgroundColor: Theme.of(context).primaryColor, child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20), onPressed: () => _pickAndUploadImage(user))))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading) const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Center(child: CircularProgressIndicator())),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Flexible(child: Text('Nombre: ${user.nombre}', style: const TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis)),
                          IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.grey), onPressed: () => _showEditNameDialog(user)),
                        ]),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text('Rol: ${user.rol}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),

                // [NUEVO] Botón de Panel de Administración
                if (canAccessPanel)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Panel de Administración'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
                        );
                      },
                    ),
                  ),

                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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