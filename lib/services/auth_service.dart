// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:avivamiento_app/services/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  /// Inicia sesión de un usuario existente con correo y contraseña.
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

  /// Verifica si un correo electrónico ya está registrado en Firebase Auth.
  Future<bool> checkIfEmailExists(String email) async {
    try {
      final signInMethods = await _firebaseAuth.fetchSignInMethodsForEmail(
        email,
      );
      return signInMethods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Envía un correo electrónico para restablecer la contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    final emailExists = await checkIfEmailExists(email);
    if (!emailExists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No existe ningún usuario con este correo electrónico.',
      );
    }
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Inicia sesión o registra a un usuario usando su cuenta de Google,
  /// y maneja la vinculación si el correo ya existe con otro proveedor.
  Future<User?> signInWithGoogle(UserService userService) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // El usuario canceló el proceso.
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await userService.createUserProfile(
          uid: user.uid,
          nombre: user.displayName ?? 'Usuario de Google',
          email: user.email!,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Lógica para vincular cuentas si el correo ya existe.
      if (e.code == 'account-exists-with-different-credential') {
        print(
          'El correo ya existe con otro proveedor. La vinculación automática aún no está implementada.',
        );
        // Por ahora, lanzamos un error más amigable para el usuario.
        throw Exception(
          'Ya tienes una cuenta creada con este correo. Por favor, inicia sesión con tu método original (correo y contraseña).',
        );
      }

      print('Error de FirebaseAuth durante Google Sign-In: ${e.message}');
      throw e; // Relanzamos otros errores de Firebase.
    } catch (e) {
      print('Error inesperado durante Google Sign-In: $e');
      throw e; // Relanzamos errores inesperados.
    }
  }

  /// Inicia sesión de forma anónima (para invitados).
  Future<String?> signInAnonymously() async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    return userCredential.user?.uid;
  }

  /// Cierra la sesión del usuario actual tanto en Firebase como en Google Sign-In.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
