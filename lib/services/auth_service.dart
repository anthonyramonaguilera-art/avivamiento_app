// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:avivamiento_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  // ... (otros métodos no cambian) ...
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, UserService userService) async {
    // ...implementación original...
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // ...implementación original...
    return null;
  }

  /// [NUEVO] Verifica si un correo electrónico ya está registrado en Firebase Auth.
  /// Devuelve 'true' si el correo existe, 'false' si no.
  Future<bool> checkIfEmailExists(String email) async {
    try {
      // Este método de Firebase devuelve una lista de los métodos de inicio de sesión
      // asociados a un correo. Si la lista no está vacía, el usuario existe.
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      // En caso de error, asumimos que no existe para estar seguros.
      return false;
    }
  }

  /// Envía un correo electrónico para restablecer la contraseña.
  /// [CAMBIO] Ahora primero verifica si el correo existe.
  Future<void> sendPasswordResetEmail(String email) async {
    final emailExists = await checkIfEmailExists(email);

    // Si el correo no existe, lanzamos una excepción personalizada.
    if (!emailExists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No existe ningún usuario con este correo electrónico.',
      );
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Error al enviar correo de reseteo: ${e.message}');
      throw e;
    }
  }

  Future<String?> signInAnonymously() async {
    // ...implementación original...
    return null;
  }

  Future<void> signOut() async { /* ... */ }
}