// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;
  // Colección de usuarios. Es una buena práctica definirla una vez.
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserService(this._firestore) {
    _usersCollection = _firestore.collection('users');
  }

  /// Crea el perfil de un usuario en Firestore después del registro.
  Future<void> createUserProfile({
    required String uid,
    required String nombre,
    required String email,
  }) async {
    await _usersCollection.doc(uid).set({
      'nombre': nombre,
      'email': email,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'rol': 'Miembro',
    });
  }

  /// Obtiene el perfil de un usuario como un Future (una sola vez).
  Future<UserModel?> getUserProfile(String uid) async {
    final docSnapshot = await _usersCollection.doc(uid).get();
    if (docSnapshot.exists) {
      return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    return null;
  }

  /// **[NUEVO]** Obtiene el perfil de un usuario como un Stream (en tiempo real).
  ///
  /// Esto nos permite escuchar cambios en el documento del usuario y actualizar
  /// la UI automáticamente. Es ideal para la pantalla de perfil.
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        // Si el documento existe, lo mapeamos a nuestro UserModel.
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      // Si no existe, emitimos null en el stream.
      return null;
    });
  }
}
