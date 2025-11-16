// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:avivamiento_app/providers/services_provider.dart'; // [NUEVO] Necesitamos los providers
import 'package:avivamiento_app/screens/auth/login_screen.dart';
import 'package:avivamiento_app/screens/auth/register_screen.dart';

/// AuthScreen: La pantalla principal de autenticación.
///
/// Ofrece al usuario las opciones para iniciar sesión, registrarse
/// o continuar como invitado.
class AuthScreen extends ConsumerWidget {
  // [CAMBIO] Ahora es ConsumerWidget
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [CAMBIO] Añadimos WidgetRef
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.15,
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Únete a nuestra comunidad',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              // Botón para ir a la pantalla de Login.
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 16),

              // Botón para ir a la pantalla de Registro.
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: const Text('Registrarse'),
              ),

              const SizedBox(height: 16),

              // --- [NUEVO Y CORREGIDO] Botón para continuar como invitado ---
              TextButton(
                onPressed: () async {
                  // Leemos el authService y llamamos al método para login anónimo.
                  // El AuthWrapper se encargará del resto automáticamente.
                  final authService = ref.read(authServiceProvider);
                  await authService.signInAnonymously();
                },
                child: const Text('Continuar como Invitado'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
