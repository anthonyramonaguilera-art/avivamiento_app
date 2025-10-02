// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/firebase_options.dart';
import 'package:avivamiento_app/screens/auth_screen.dart';
import 'package:avivamiento_app/screens/home_screen.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';
import 'package:avivamiento_app/providers/services_provider.dart'; // Asegúrate de que este import sea el correcto

void main() async {
  // Asegura que Flutter esté inicializado antes de usar plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase con las opciones específicas de la plataforma.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ProviderScope es el widget raíz que permite que toda la app acceda a los providers de Riverpod.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado de autenticación. Riverpod manejará la reconstrucción del widget.
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Avivamiento App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // El método .when es la forma elegante de manejar estados asíncronos (carga, error, datos).
      home: authState.when(
        data: (user) {
          // Si tenemos un usuario (no es nulo), mostramos la pantalla principal.
          if (user != null) {
            return const HomeScreen();
          }
          // Si el usuario es nulo, mostramos la pantalla de autenticación.
          return const AuthScreen();
        },
        // Mientras se determina el estado de autenticación, mostramos una pantalla de carga.
        loading: () => const SplashScreen(),
        // Si hay un error al verificar la autenticación, mostramos un mensaje.
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
