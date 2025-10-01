import 'package:firebase_core/firebase_core.dart'; // Importa para inicializar Firebase
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importa Riverpod
import 'firebase_options.dart'; // Importa el archivo de opciones de Firebase

// Importa las pantallas que crearemos
import 'package:avivamiento_app/screens/auth_screen.dart';
import 'package:avivamiento_app/screens/home_screen.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';

// Importa el StreamProvider que escucha los cambios de autenticación
import 'package:avivamiento_app/providers/services_provider.dart';

void main() async {
  // Asegura que los widgets de Flutter estén inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones generadas.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ejecuta la aplicación envuelta en ProviderScope para Riverpod.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // Ahora es ConsumerWidget para usar Riverpod
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Recibe WidgetRef
    // 1. Escuchar el estado de autenticación
    // Cuando el estado de authStateChangesProvider cambie (usuario logeado/deslogeado),
    // esta parte de la UI se reconstruirá automáticamente.
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Avivamiento App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: authState.when(
        data: (user) {
          // Si hay un usuario (no nulo), mostrar HomeScreen.
          // user.uid será String, no String?, gracias a la lógica en AuthService.
          return user != null ? const HomeScreen() : const AuthScreen();
        },
        loading: () =>
            const SplashScreen(), // Mientras carga, mostrar SplashScreen.
        error: (error, stack) {
          // Si hay un error, mostrar una pantalla de error simple (o logearlo).
          print('Error de autenticación: $error'); // Para depuración
          return const Scaffold(
            body: Center(child: Text('Ocurrió un error al cargar la app.')),
          );
        },
      ),
    );
  }
}
