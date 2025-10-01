// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

// Usamos un StateProvider para manejar el estado de carga
final isLoadingProvider = StateProvider<bool>((ref) => false);

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final isLoading = ref.watch(
      isLoadingProvider,
    ); // Observamos el estado de carga

    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Por favor, inicia sesión para continuar.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            if (isLoading)
              const CircularProgressIndicator() // Mostramos el indicador si está cargando
            else
              ElevatedButton(
                onPressed: () async {
                  ref.read(isLoadingProvider.notifier).state =
                      true; // Inicia la carga
                  try {
                    final uid = await authService.signInAnonymously();
                    print('Usuario anónimo logeado con UID: $uid');
                  } catch (e) {
                    print('Error al iniciar sesión anónimamente: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    ref.read(isLoadingProvider.notifier).state =
                        false; // Finaliza la carga
                  }
                },
                child: const Text('Iniciar Sesión Anónimamente'),
              ),
          ],
        ),
      ),
    );
  }
}
