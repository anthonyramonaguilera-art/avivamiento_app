import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';
import 'package:avivamiento_app/screens/bible_search_screen.dart';
import 'package:avivamiento_app/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:avivamiento_app/providers/audio_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // --- INICIO DE LA INICIALIZACIÓN DEL AUDIO ---
  // Inicializa el servicio de audio en segundo plano y obtiene el handler
  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.avivamiento_app.radio',
      androidNotificationChannelName: 'Radio Avivamiento',
      androidNotificationOngoing: true,
    ),
  );
  // --- FIN DE LA INICIALIZACIÓN DEL AUDIO ---

  // Inicializa Firebase (seguimos usando el fallback try/catch para mayor
  // resiliencia si `firebase_options.dart` no está presente localmente).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    await Firebase.initializeApp();
  }

  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribimos el provider con la instancia real del handler
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicialización de notificaciones
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationServiceProvider).initNotifications();
      });
    }

    return MaterialApp(
      title: 'Avivamiento App',
      debugShowCheckedModeBanner: false,

      // Tema de la aplicación
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

      // Rutas de la aplicación
      routes: {
        '/bible-search': (context) => const BibleSearchScreen(),
        // Agrega aquí más rutas según sea necesario
      },

      // Pantalla inicial
      home: const SplashScreen(),
    );
  }
}
