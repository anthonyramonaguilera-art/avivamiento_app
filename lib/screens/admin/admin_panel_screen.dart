// lib/screens/admin/admin_panel_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/admin/admin_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/utils/constants.dart';

/// Pantalla exclusiva para la gestión de roles de los usuarios.
/// Solo accesible para roles de Pastor y Admin.
class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  /// Muestra un diálogo que permite al Admin seleccionar y cambiar el rol de un usuario.
  Future<void> _showChangeRoleDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel userToEdit,
  ) {
    // Usamos un StateProvider temporal para manejar el rol seleccionado dentro del diálogo.
    final selectedRoleProvider = StateProvider<String>((_) => userToEdit.rol);
    final userService = ref.read(userServiceProvider);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // Usamos un Consumer para que el diálogo se reconstruya cuando cambia el rol seleccionado.
        return Consumer(builder: (context, dialogRef, child) {
          final currentSelectedRole = dialogRef.watch(selectedRoleProvider);

          return AlertDialog(
            title: Text('Cambiar Rol a ${userToEdit.nombre}'),
            content: DropdownButton<String>(
              value: currentSelectedRole,
              isExpanded: true,
              // Usamos la lista de roles del archivo de constantes
              items: AppConstants.allRoles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  dialogRef.read(selectedRoleProvider.notifier).state =
                      newValue;
                }
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                onPressed: currentSelectedRole == userToEdit.rol
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        try {
                          await userService.updateUserRole(
                            uid: userToEdit.id,
                            newRole: currentSelectedRole,
                          );
                          // Mostramos una confirmación al usuario.
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Rol de ${userToEdit.nombre} cambiado a $currentSelectedRole',
                            ),
                          ));
                        } catch (e) {
                          // Mostramos un error si algo falla.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cambiar el rol: $e'),
                            ),
                          );
                        }
                      },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el stream de todos los usuarios
    final allUsersAsync = ref.watch(allUsersProvider);
    // Obtenemos el perfil del usuario actual para verificar permisos
    final currentUser = ref.watch(userProfileProvider).value;

    // 1. Verificación de permisos (seguridad en la UI)
    // Comprobamos si el rol del usuario actual está en la lista de roles de administrador.
    final bool canAccessPanel = currentUser != null &&
        [AppConstants.rolePastor, AppConstants.roleAdmin]
            .contains(currentUser.rol);

    if (!canAccessPanel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de Administración')),
        body: const Center(
          child: Text('Acceso denegado. Solo para Pastor o Admin.'),
        ),
      );
    }

    // 2. Mostrar la lista de usuarios
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Roles'),
      ),
      body: allUsersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error al cargar usuarios: $err')),
        data: (users) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // No permitimos que el usuario cambie su propio rol
              final bool isCurrentUser = user.id == currentUser.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                            ? NetworkImage(user.fotoUrl!)
                            : null,
                    child: user.fotoUrl == null || user.fotoUrl!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.nombre),
                  subtitle: Text('Rol: ${user.rol}'),
                  trailing: isCurrentUser
                      ? const Chip(
                          label: Text('Tú'),
                          backgroundColor: Colors.transparent)
                      : IconButton(
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: () =>
                              _showChangeRoleDialog(context, ref, user),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
