import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa el tipo User
import 'package:avivamiento_app/services/services_provider.dart'; // Importa tus providers

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el usuario actual para mostrar su UID
    final user = ref
        .watch(authStateChangesProvider)
        .value; // Obtiene el valor actual del StreamProvider
    final authService = ref.watch(
      authServiceProvider,
    ); // Necesitamos el AuthService para cerrar sesión

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avivamiento App - Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                // Llama al método signOut de tu AuthService
                await authService.signOut();
                print('Sesión cerrada correctamente.'); // Para depuración
                // Riverpod detectará el cambio en authStateChangesProvider
                // y MyApp reconstruirá para mostrar AuthScreen.
              } catch (e) {
                print('Error al cerrar sesión: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Bienvenido!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Muestra el UID del usuario si está disponible
            if (user != null)
              Text(
                'Tu UID es: ${user.uid}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40),
            const Text('Esta es tu pantalla principal.'),
          ],
        ),
      ),
    );
  }
}
