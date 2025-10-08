// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:avivamiento_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// Stream que notifica sobre los cambios de estado de autenticación (login/logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Registra un nuevo usuario con correo, contraseña y nombre.
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserService userService,
  ) async {
    // ... (este método no cambia)
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await userService.createUserProfile(
          uid: user.uid,
          nombre: name,
          email: email,
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Error de registro en Firebase: ${e.message}');
      throw e;
    }
  }

  /// Inicia sesión de un usuario existente.
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // ... (este método no cambia)
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error de inicio de sesión en Firebase: ${e.message}');
      throw e;
    }
  }

  /// [NUEVO] Envía un correo electrónico para restablecer la contraseña.
  /// Lanza una excepción [FirebaseAuthException] si el correo no es válido o no existe.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Relanzamos la excepción para que la UI pueda manejar el error y mostrárselo al usuario.
      print('Error al enviar correo de reseteo: ${e.message}');
      throw e;
    }
  }

  /// Inicia sesión de forma anónima (para invitados).
  Future<String?> signInAnonymously() async {
    // ... (este método no cambia)
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user?.uid;
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    // ... (este método no cambia)
    await _firebaseAuth.signOut();
  }
}