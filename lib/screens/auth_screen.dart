// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importamos flutter_svg

import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/auth/login_screen.dart';
import 'package:avivamiento_app/screens/auth/register_screen.dart';

/// AuthScreen: La pantalla principal de autenticación.
///
/// Ofrece al usuario las opciones para iniciar sesión, registrarse
/// o continuar como invitado.
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              
              // Logo con animación sutil (Hero si se usa en otro lado)
              Hero(
                tag: 'app_logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  height: screenHeight * 0.18,
                ),
              ),
              
              const SizedBox(height: 40),
              
              Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Únete a nuestra comunidad de fe y avivamiento.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const Spacer(flex: 3),

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
                child: const Text('Registrarse'),
              ),

              const SizedBox(height: 24),

              // Botón para continuar como invitado
              TextButton(
                onPressed: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signInAnonymously();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Continuar como Invitado'),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
