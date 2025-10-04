// lib/main.dart

import 'package:flutter/foundation.dart'; // [IMPORTANTE] Añade esta línea
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/firebase_options.dart';
import 'package:avivamiento_app/screens/auth_screen.dart';
import 'package:avivamiento_app/screens/home_screen.dart';
import 'package:avivamiento_app/screens/splash_screen.dart';
import 'package:avivamiento_app/providers/auth_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();

  // [CORRECCIÓN] Solo inicializamos las notificaciones si no estamos en la web.
  if (!kIsWeb) {
    await container.read(notificationServiceProvider).initNotifications();
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Avivamiento App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
        loading: () => const SplashScreen(),
        error: (err, stack) =>
            Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
