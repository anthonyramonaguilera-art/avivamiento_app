// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:avivamiento_app/firebase_options.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';
import 'package:avivamiento_app/screens/bible_search_screen.dart'; // <-- 1. IMPORTA LA NUEVA PANTALLA

void main() async {
  // Asegura que los bindings de Flutter estén inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carga las variables de entorno del archivo .env ANTES de usarlas.
  await dotenv.load(fileName: ".env");

  // 3. Inicializa Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();

  // Inicializa las notificaciones (solo si no estamos en la web).
  if (!kIsWeb) {
    await container.read(notificationServiceProvider).initNotifications();
  }

  // Ejecuta la app dentro de un ProviderScope para que Riverpod funcione.
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// El widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avivamiento App',
      debugShowCheckedModeBanner: false,

      // --- TEMA GLOBAL DE LA APLICACIÓN ---
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF64B5F6),
          background: Colors.grey[50],
          surface: Colors.white,
          error: Colors.redAccent,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 12.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1565C0),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),

      // --- FIN DEL TEMA ---
      
      // 2. REGISTRA LA RUTA DE LA NUEVA PANTALLA
      routes: {
        BibleSearchScreen.routeName: (context) => const BibleSearchScreen(),
      },
      
      // La ruta inicial sigue siendo tu SplashScreen
      home: const SplashScreen(),
    );
  }
}