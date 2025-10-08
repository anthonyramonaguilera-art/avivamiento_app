// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/auth/login_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userService = ref.read(
      userServiceProvider,
    ); // [NUEVO] Necesitamos el UserService

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.church, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido a\nCentro Internacional Avivamiento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // [NUEVO] Botón de inicio de sesión con Google
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.login,
                ), // Puedes cambiar este ícono por un logo de Google si lo deseas
                label: const Text('Continuar con Google'),
                onPressed: () async {
                  try {
                    // Llamamos al nuevo método en nuestro servicio
                    await authService.signInWithGoogle(userService);
                    // Si el login es exitoso, el authStateChangesProvider nos llevará a HomeScreen automáticamente.
                  } catch (e) {
                    // Mostramos un error si algo falla durante el proceso.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al iniciar sesión con Google: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Color de Google
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Iniciar Sesión con Correo'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await authService.signInAnonymously();
                },
                child: const Text('Continuar como Invitado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
