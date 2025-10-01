// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:avivamiento_app/services/user_service.dart'; // Necesario para crear el perfil

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Stream que notifica sobre los cambios de estado de autenticación (login/logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// **[NUEVO]** Registra un nuevo usuario con correo, contraseña y nombre.
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserService userService,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        // Después de registrar, creamos su perfil en Firestore.
        await userService.createUserProfile(
          uid: user.uid,
          nombre: name,
          email: email,
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores específicos (ej. correo ya en uso).
      print('Error de registro en Firebase: ${e.message}');
      throw e; // Relanzamos la excepción para que la UI la pueda manejar.
    }
  }

  /// **[NUEVO]** Inicia sesión de un usuario existente.
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores (ej. contraseña incorrecta, usuario no encontrado).
      print('Error de inicio de sesión en Firebase: ${e.message}');
      throw e;
    }
  }

  /// Inicia sesión de forma anónima (para invitados).
  Future<String?> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user?.uid;
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
