import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/services/services_provider.dart'; // Asegúrate de importar tu provider

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha al provider para el Auth Service.
    final authService = ref.watch(authServiceProvider);

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
            ElevatedButton(
              onPressed: () async {
                try {
                  // Llama al método signInAnonymously de tu AuthService
                  // El ref.read() se usa para llamar a métodos que no necesitamos
                  // que reconstruyan el widget al cambiar.
                  final uid = await authService.signInAnonymously();
                  print(
                    'Usuario anónimo logeado con UID: $uid',
                  ); // Para depuración
                  // Riverpod detectará el cambio en authStateChangesProvider
                  // y MyApp reconstruirá para mostrar HomeScreen.
                } catch (e) {
                  print('Error al iniciar sesión anónimamente: $e');
                  // Aquí puedes mostrar un SnackBar o AlertDialog al usuario
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Iniciar Sesión Anónimamente'),
            ),
            // Puedes añadir más botones para login con email/password, Google, etc.
          ],
        ),
      ),
    );
  }
}
