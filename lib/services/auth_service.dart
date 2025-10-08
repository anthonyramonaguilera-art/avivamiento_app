// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // [NUEVO]
import 'package:avivamiento_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  // [NUEVO] Instancia para manejar el flujo de Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._firebaseAuth);

  // ... (métodos existentes no cambian) ...
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  Future<User?> signUpWithEmailAndPassword(String email, String password, String name, UserService userService) async {
    // TODO: Implementar lógica de registro
    return null;
  }
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // TODO: Implementar lógica de login
    return null;
  }
  Future<void> sendPasswordResetEmail(String email) async {
    // TODO: Implementar lógica de reset de contraseña
  }
  Future<bool> checkIfEmailExists(String email) async {
    // TODO: Implementar lógica de verificación
    return false;
  }
  Future<String?> signInAnonymously() async {
    // TODO: Implementar lógica de login anónimo
    return null;
  }
  Future<void> signOut() async {
    // TODO: Implementar lógica de logout
  }

  /// [NUEVO] Inicia sesión o registra a un usuario usando su cuenta de Google.
  Future<User?> signInWithGoogle(UserService userService) async {
    try {
      // 1. Inicia el flujo de autenticación de Google.
      // Esto mostrará el pop-up nativo para que el usuario elija su cuenta.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el proceso de selección de cuenta.
        return null;
      }

      // 2. Obtenemos los detalles de autenticación de la cuenta de Google.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Creamos una credencial de Firebase a partir de los tokens de Google.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Usamos la credencial para iniciar sesión en Firebase.
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // 5. [IMPORTANTE] Verificamos si es un usuario nuevo.
      // Si es la primera vez que inicia sesión, creamos su perfil en Firestore.
      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        await userService.createUserProfile(
          uid: user.uid,
          nombre: user.displayName ?? 'Usuario de Google', // Usamos el nombre de su cuenta de Google
          email: user.email!, // El email siempre estará disponible con Google
        );
      }

      return user; // Devolvemos el usuario de Firebase.

    } on FirebaseAuthException catch (e) {
      print('Error de FirebaseAuth durante Google Sign-In: ${e.message}');
      throw e;
    } catch (e) {
      print('Error inesperado durante Google Sign-In: $e');
      throw e;
    }
  }
}