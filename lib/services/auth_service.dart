// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // <--- AÑADE ESTA LÍNEA
import 'package:avivamiento_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  //... dentro de la clase AuthService

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  //...

  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- INICIO DE SESIÓN CON GOOGLE ---
  Future<User?> signInWithGoogle(UserService userService) async {
    try {
      // 1. Inicia el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // El usuario canceló el proceso
        return null;
      }

      // 2. Obtiene los detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crea una credencial de Firebase con el token de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Inicia sesión en Firebase con la credencial
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      // 5. Verifica si es un usuario nuevo para crear su perfil en Firestore
      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await userService.createUserProfile(
          uid: user.uid,
          nombre: user.displayName ?? 'Sin Nombre',
          email: user.email!,
        );
      }

      return user;
    } catch (e) {
      print('Error en signInWithGoogle: $e');
      rethrow; // Lanza el error para que la UI lo pueda manejar
    }
  }

  // --- MÉTODOS EXISTENTES ---

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
      print('Error de inicio de sesión en Firebase: ${e.message}');
      throw e;
    }
  }

  Future<String?> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user?.uid;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // Cierra también la sesión de Google
    await _firebaseAuth.signOut();
  }
}
