// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// La pantalla de perfil del usuario.
///
/// Utiliza un [ConsumerWidget] para poder escuchar los cambios de los proveedores de Riverpod.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor del perfil de usuario.
    // Riverpod nos devuelve un AsyncValue, que contiene el estado (data, loading, error).
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      // Usamos el método .when() de AsyncValue para construir la UI según el estado.
      // Esto es una buena práctica para manejar estados asíncronos de forma limpia.
      body: userProfile.when(
        // Estado de carga: mostramos un indicador de progreso.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Estado de error: mostramos un mensaje de error.
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        // Estado de éxito: tenemos los datos y construimos la UI principal.
        data: (user) {
          // Si por alguna razón el usuario es nulo (ej. se deslogueó), mostramos un mensaje.
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado.'));
          }

          // Construimos la vista del perfil con los datos del usuario.
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Círculo para la foto de perfil (placeholder por ahora).
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 24),
                // Tarjeta con la información del usuario.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre: ${user.nombre}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${user.email}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rol: ${user.rol}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(), // Ocupa el espacio restante.
                // Botón para cerrar sesión.
                ElevatedButton(
                  onPressed: () {
                    // Accedemos al servicio de autenticación para cerrar sesión.
                    ref.read(authServiceProvider).signOut();
                    // Volvemos a la pantalla anterior (o a la pantalla de login).
                    Navigator.of(context).pop();
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
