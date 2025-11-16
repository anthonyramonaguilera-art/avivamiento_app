// lib/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:avivamiento_app/providers/auth_provider.dart';
import 'package:avivamiento_app/screens/auth_screen.dart';
import 'package:avivamiento_app/screens/home_screen.dart';

/// AuthWrapper es un widget que decide qué pantalla mostrar
/// basado en el estado de autenticación del usuario.
/// Actúa como un "guardián" de la autenticación.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el stream de cambios de autenticación desde Riverpod.
    final authState = ref.watch(authStateChangesProvider);

    // .when() es la forma idiomática de Riverpod para manejar los diferentes
    // estados de un provider asíncrono (cargando, con datos, con error).
    return authState.when(
      data: (user) {
        // Si el objeto 'user' no es nulo, significa que el usuario está logueado.
        if (user != null) {
          return const HomeScreen();
        }
        // Si 'user' es nulo, el usuario no está logueado.
        return const AuthScreen();
      },
      // Mientras se determina el estado inicial, mostramos un indicador de carga.
      // Esto previene parpadeos en la UI.
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Si hay un error al obtener el estado, lo mostramos en la pantalla.
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Ocurrió un error: $err'))),
    );
  }
}
