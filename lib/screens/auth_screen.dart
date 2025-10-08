/// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/auth/login_screen.dart';

/// La pantalla inicial que el usuario ve si no está autenticado.
/// Ofrece las opciones principales de autenticación.
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Iniciar Sesión o Registrarse'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  // Mantenemos la lógica de invitado anónimo
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
