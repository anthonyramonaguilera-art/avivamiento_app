// lib/services/post_service.dart

import 'dart:convert'; // [NUEVO] Para codificar la imagen en base64
import 'package:flutter/foundation.dart';
import 'package:http/http.dart'
    as http; // [NUEVO] Para hacer la petición a ImgBB
import 'package:flutter_dotenv/flutter_dotenv.dart'; // [NUEVO] Para leer la API Key
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para gestionar las operaciones de las publicaciones en Firestore.
class PostService {
  final FirebaseFirestore _firestore;
  // [ELIMINADO] Ya no necesitamos FirebaseStorage
  // final FirebaseStorage _storage;

  late final CollectionReference<Map<String, dynamic>> _postsCollection;

  // [MODIFICADO] El constructor ya no necesita Storage
  PostService(this._firestore) {
    _postsCollection = _firestore.collection('posts');
  }

  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// [MODIFICADO] Sube una imagen al servicio ImgBB y devuelve la URL.
  Future<String> _uploadImageToImgbb(XFile imageFile) async {
    final apiKey = dotenv.env['IMGBB_API_KEY'];
    if (apiKey == null) {
      throw Exception('IMGBB_API_KEY no encontrada en el archivo .env');
    }

    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');
    final request = http.MultipartRequest('POST', uri);

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    request.fields['image'] = base64Image;

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['data']['url'];
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception(
        'Fallo al subir la imagen a ImgBB: ${response.statusCode} - $errorBody',
      );
    }
  }

  /// Crea una nueva publicación en Firestore.
  Future<void> createPost({
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String authorRole,
    XFile? imageFile,
  }) async {
    String? imageUrl;

    // Si se adjuntó una imagen, la subimos a ImgBB.
    if (imageFile != null) {
      imageUrl = await _uploadImageToImgbb(imageFile);
    }

    await _postsCollection.add({
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'imageUrl': imageUrl, // Guardamos la URL de ImgBB
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
    });
  }
}
