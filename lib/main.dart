// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';
import 'package:avivamiento_app/screens/bible_search_screen.dart';
import 'package:avivamiento_app/services/audio_handler.dart';
import 'package:avivamiento_app/services/legend_service.dart';
import 'package:avivamiento_app/services/backend/firestore_legend_backend.dart';
import 'package:audio_service/audio_service.dart';
import 'package:avivamiento_app/providers/audio_provider.dart';
import 'package:avivamiento_app/utils/theme.dart';

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

  // Inicializar locale español para intl (fechas)
  await initializeDateFormatting('es', null);

  await dotenv.load(fileName: ".env");

  // --- INICIO DE LA INICIALIZACIÓN DEL AUDIO ---
  // Intentamos inicializar el servicio de audio, pero con tolerancia:
  // - timeout para no bloquear indefinidamente
  // - try/catch para capturar errores nativos
  AudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(), // <-- TU FRACASO
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.avivamiento_app.radio',
        androidNotificationChannelName: 'Radio Avivamiento',
        androidNotificationOngoing: true,
      ),
    );

    // AÑADIDO: Línea de diagnóstico para confirmar la inicialización
    if (kDebugMode) {
      // ignore: avoid_print
    }
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('AudioService.init failed or timed out: $e');
      // ignore: avoid_print
      print(st);
    }

    if (kDebugMode) {}

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

  // Inicializa las leyendas predeterminadas si no existen
  try {
    final legendBackend = FirestoreLegendBackend(FirebaseFirestore.instance);
    final legendService = LegendService(legendBackend);
    // Usamos un ID temporal para la inicialización
    await legendService.initializeDefaultLegends('system');
  } catch (e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Error inicializando leyendas: $e');
    }
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
      theme: AppTheme.lightTheme,

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
