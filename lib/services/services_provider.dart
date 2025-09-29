// lib/providers/services_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// 1. Provider para la instancia de FirebaseAuth.
// Otros providers pueden usar este para obtener la instancia de FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// 2. Provider para nuestro AuthService.
// Este provider crea una instancia de AuthService, pasándole la instancia de FirebaseAuth
// que obtiene del provider anterior.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

// 3. StreamProvider para el estado de autenticación.
// Este es un provider especial que escucha un Stream y expone sus valores.
// Nuestra UI escuchará este provider para reaccionar a los cambios de login/logout.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  // "ref.watch" se suscribe al authServiceProvider. Si ese provider cambiara,
  // este también se reconstruiría.
  return ref.watch(authServiceProvider).authStateChanges;
});
