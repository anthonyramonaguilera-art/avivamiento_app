// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para gestionar todas las operaciones relacionadas con los usuarios en Firestore.
class UserService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserService(this._firestore) {
    _usersCollection = _firestore.collection('users');
  }

  // ... (los métodos createUserProfile, getUserProfileStream, uploadProfilePictureToImgbb, y updateUserProfile no cambian)
  Future<void> createUserProfile({
    required String uid,
    required String nombre,
    required String email,
  }) {
    return _usersCollection.doc(uid).set({
      'nombre': nombre,
      'email': email,
      'rol': 'Miembro',
      'fotoUrl': null,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  Stream<UserModel?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<String> uploadProfilePictureToImgbb(XFile imageFile) async {
    const String apiKey = '274c1e89728ce7d94428026b73b12cad';
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri);
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);
    request.fields['image'] = base64Image;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final imageUrl = jsonResponse['data']['url'];
        return imageUrl;
      } else {
        throw Exception('Fallo al subir la imagen. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al subir la imagen a ImgBB: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? nombre,
    String? fotoUrl,
  }) {
    final Map<String, dynamic> dataToUpdate = {};
    if (nombre != null) dataToUpdate['nombre'] = nombre;
    if (fotoUrl != null) dataToUpdate['fotoUrl'] = fotoUrl;

    if (dataToUpdate.isNotEmpty) {
      return _usersCollection.doc(uid).update(dataToUpdate);
    }
    return Future.value();
  }

  /// [NUEVO] Obtiene un Stream con la lista de todos los usuarios de la aplicación.
  /// Ordena los usuarios por fecha de registro para mostrar los más nuevos primero.
  Stream<List<UserModel>> getAllUsersStream() {
    return _usersCollection
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// [NUEVO] Actualiza el rol de un usuario específico.
  /// Esta es una operación delicada y debe estar protegida por reglas de seguridad.
  Future<void> updateUserRole({required String uid, required String newRole}) {
    return _usersCollection.doc(uid).update({'rol': newRole});
  }
}