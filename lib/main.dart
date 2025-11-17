// lib/main.dart
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

class NoOpAudioHandler extends BaseAudioHandler {
  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> seek(Duration position) async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // --- INICIO DE LA INICIALIZACIÓN DEL AUDIO ---
  // Intentamos inicializar el servicio de audio, pero con tolerancia:
  // - timeout para no bloquear indefinidamente
  // - try/catch para capturar errores nativos
  AudioHandler audioHandler;
  try {
    // Damos más tiempo a la inicialización del servicio de audio en
    // dispositivos más lentos o cuando hay demoras nativas.
    audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.avivamiento_app.radio',
        androidNotificationChannelName: 'Radio Avivamiento',
        androidNotificationOngoing: true,
      ),
    ).timeout(const Duration(seconds: 20));

    // AÑADIDO: Línea de diagnóstico para confirmar la inicialización
    print('!!!!!!!!!!!!!! [MAIN] AudioService.init SUCCEEDED !!!!!!!!!!!!!!');
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('AudioService.init failed or timed out: $e');
      // ignore: avoid_print
      print(st);
    }
    // Si la inicialización falla seguimos con un handler no operativo
    // para no bloquear la UI. En la mayor parte de los casos el problema
    // se soluciona aumentando el timeout.
    // AÑADIDO: Línea de diagnóstico indicando que se usará el handler de fallback
    print('!!!!!!!!!!!!!! [MAIN] FALLBACK TO NoOpAudioHandler !!!!!!!!!!!!!!');

    audioHandler = NoOpAudioHandler();
  }

  // --- FIN DE LA INICIALIZACIÓN DEL AUDIO ---

  // Inicializa Firebase (seguimos usando el fallback try/catch para mayor
  // resiliencia si `firebase_options.dart` no está presente localmente).
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Si falla la primera, intenta de nuevo.
    // Aunque si `firebase_options.dart` está bien generado,
    // la primera llamada debería bastar.
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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Puesta segura: espera un breve intervalo para asegurar que
        // la Activity/FlutterEngine esté correctamente inicializada
        // y evita que una excepción nativa bloquee la UI al inicio.
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          await ref.read(notificationServiceProvider).initNotifications();
        } catch (e, st) {
          // Loguea el error pero no detiene la interfaz de usuario.
          if (kDebugMode) {
            // ignore: avoid_print
            print('Error inicializando notificaciones: $e');
            // ignore: avoid_print
            print(st);
          }
        }
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
