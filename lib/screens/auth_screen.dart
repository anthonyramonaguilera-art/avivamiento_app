// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';

import 'package:avivamiento_app/screens/auth/login_screen.dart';
import 'package:avivamiento_app/screens/auth/register_screen.dart';

/// AuthScreen: La pantalla principal de autenticación.
///
/// Ofrece al usuario las opciones para navegar a la pantalla de inicio de sesión
/// o a la de registro. El diseño es minimalista y centrado, utilizando el
/// tema global de la aplicación para los estilos de los botones.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos las dimensiones de la pantalla para un diseño adaptable.
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Usamos el color de fondo definido en nuestro ThemeData.
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espacio flexible en la parte superior para centrar el contenido.
              const Spacer(),

              // El logo de la iglesia.
              Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.15, // 15% de la altura de la pantalla
              ),
              const SizedBox(height: 20),

              // Título de bienvenida
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Subtítulo
              Text(
                'Únete a nuestra comunidad',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              // Botón para ir a la pantalla de Login.
              // El estilo se toma automáticamente del `elevatedButtonTheme` en main.dart.
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
              // Usamos un OutlinedButton para darle una jerarquía visual diferente,
              // siendo esta la acción secundaria.
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

              // Espacio flexible en la parte inferior.
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
