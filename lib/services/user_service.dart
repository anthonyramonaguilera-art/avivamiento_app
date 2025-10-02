// lib/services/user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para gestionar todas las operaciones relacionadas con los usuarios en Firestore
/// y el almacenamiento de imágenes de perfil.
class UserService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserService(this._firestore) {
    _usersCollection = _firestore.collection('users');
  }

  /// Crea el documento de perfil para un nuevo usuario en Firestore.
  /// Se llama justo después de que un usuario se registra.
  Future<void> createUserProfile({
    required String uid,
    required String nombre,
    required String email,
  }) {
    // Aseguramos que se creen todos los campos iniciales del perfil.
    return _usersCollection.doc(uid).set({
      'nombre': nombre,
      'email': email,
      'rol': 'Miembro', // El rol por defecto para nuevos usuarios.
      'fotoUrl': null, // La foto de perfil empieza vacía.
      'fechaRegistro':
          FieldValue.serverTimestamp(), // Usamos la hora del servidor.
    });
  }

  /// Obtiene un Stream del perfil de un usuario para actualizaciones en tiempo real.
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      // Si el documento no existe, emitimos null.
      return null;
    });
  }

  /// Sube la imagen de perfil a ImgBB y devuelve la URL de la imagen.
  Future<String> uploadProfilePictureToImgbb(XFile imageFile) async {
    // ⚠️ ¡IMPORTANTE! Pega aquí la API Key que obtuviste de imgbb.com
    const String apiKey = '274c1e89728ce7d94428026b73b12cad';

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri);

    // Lee los bytes de la imagen de una manera compatible con web y móvil.
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    request.fields['image'] = base64Image;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        if (jsonResponse['data'] != null &&
            jsonResponse['data']['url'] != null) {
          final imageUrl = jsonResponse['data']['url'];
          return imageUrl;
        } else {
          throw Exception(
            'La respuesta de la API de ImgBB no tuvo el formato esperado.',
          );
        }
      } else {
        throw Exception(
          'Fallo al subir la imagen. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error al subir la imagen a ImgBB: $e');
      rethrow; // Relanza el error para que la UI pueda manejarlo.
    }
  }

  /// Actualiza los datos de un perfil de usuario en Firestore.
  Future<void> updateUserProfile({
    required String uid,
    String? nombre,
    String? fotoUrl,
  }) {
    final Map<String, dynamic> dataToUpdate = {};
    if (nombre != null) dataToUpdate['nombre'] = nombre;
    if (fotoUrl != null) dataToUpdate['fotoUrl'] = fotoUrl;

    // Solo ejecutamos la escritura si hay datos que actualizar.
    if (dataToUpdate.isNotEmpty) {
      return _usersCollection.doc(uid).update(dataToUpdate);
    }
    return Future.value(); // Si no hay nada que actualizar, completamos el Future.
  }
}
