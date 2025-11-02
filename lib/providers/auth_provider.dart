// lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que escucha los cambios de estado de autenticación de Firebase.
/// La aplicación reaccionará a este provider para mostrar la pantalla de Home o la de Login.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  // Escucha el AuthService para acceder a su stream de cambios de estado.
  return ref.watch(authServiceProvider).authStateChanges;
});
