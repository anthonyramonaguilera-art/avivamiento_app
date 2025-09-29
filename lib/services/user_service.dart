import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/user_model.dart'; // Importa tu UserModel

/// Servicio para interactuar con los datos de usuario en Firestore.
class UserService {
  final FirebaseFirestore _firestore; // Instancia de Firestore
  final CollectionReference
  _usersCollection; // Referencia a la colección 'users'

  UserService(this._firestore)
    : _usersCollection = _firestore.collection('users');

  /// Crea un nuevo perfil de usuario en Firestore.
  /// Toma un UserModel y guarda sus datos.
  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
  }

  /// Obtiene un perfil de usuario de Firestore por su ID.
  /// Devuelve el UserModel si existe, o null si no.
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// Actualiza un perfil de usuario existente en Firestore.
  /// Solo actualiza los campos proporcionados.
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _usersCollection.doc(userId).update(data);
  }

  // Puedes añadir más métodos aquí, como eliminar usuario, etc.
}
