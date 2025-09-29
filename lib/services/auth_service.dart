// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

/// Servicio que encapsula toda la lógica de autenticación con Firebase Auth.
/// Esto nos permite tener un único lugar para manejar el login, logout, etc.
/// y facilita las pruebas al poder "simular" (mock) esta clase.
class AuthService {
  // Instancia privada de FirebaseAuth para interactuar con el servicio de Firebase.
  final FirebaseAuth _firebaseAuth;

  // Constructor que recibe una instancia de FirebaseAuth.
  // Esto se llama Inyección de Dependencias y es clave para las pruebas.
  AuthService(this._firebaseAuth);

  /// Stream que notifica los cambios en el estado de autenticación del usuario.
  /// Por ejemplo, cuando inicia sesión, se cierra sesión o el token se refresca.
  /// La UI escuchará este stream para saber si mostrar la pantalla de login o la de inicio.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Inicia sesión con correo electrónico y contraseña.
  /// Devuelve el UID del usuario si el inicio de sesión es exitoso.
  /// Lanza una excepción [FirebaseAuthException] si las credenciales son incorrectas.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException {
      // Re-lanzamos la excepción para que la UI pueda manejarla (ej. mostrar un mensaje de error).
      rethrow;
    }
  }

  /// Inicia sesión de forma anónima (modo invitado).
  /// Útil para el flujo de usuario "Invitado" definido en tu PRD.
  Future<String> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw Exception('No se pudo obtener el UID del usuario anónimo');
    }
    return uid;
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
