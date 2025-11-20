// lib/services/post_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:avivamiento_app/services/upload_service.dart';
import 'package:avivamiento_app/models/post_model.dart';

class PostService {
  // ⚠️ REEMPLAZA con tu URL base (la misma que usaste en upload_service.dart pero SIN la ruta final)
  final String _apiBaseUrl =
      'https://kw64z1i0pk.execute-api.us-east-1.amazonaws.com';

  final UploadService _uploadService = UploadService();

  Future<void> createPost({
    required String content,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String authorRole,
    XFile? imageFile,
  }) async {
    String? imageKey;

    try {
      // 1. Subir a S3 (si hay foto)
      if (imageFile != null) {
        print('📸 Iniciando subida de imagen a S3...');
        final file = File(imageFile.path);
        imageKey = await _uploadService.uploadImageToS3(file);

        if (imageKey == null) {
          throw Exception('Fallo la subida de la imagen a S3');
        }
        print('✅ Imagen subida. Key: $imageKey');
      }

      // 2. Enviar metadatos a Lambda
      final url = Uri.parse('$_apiBaseUrl/create-post');

      final body = {
        "userId": authorId,
        "authorName": authorName,
        "content": content,
        "imageKey": imageKey,
        "authorRole": authorRole,
        "authorPhotoUrl": authorPhotoUrl,
      };

      print('🚀 Enviando datos del post a: $url');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('📡 Respuesta AWS: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error al crear post en BD: ${response.body}');
      }
    } catch (e) {
      print('❌ Error crítico en createPost: $e');
      rethrow;
    }
  }

  Stream<List<PostModel>> getPostsStream() async* {
    try {
      final url = Uri.parse('$_apiBaseUrl/feed');
      print('📥 Solicitando feed a: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La Lambda devuelve: { "message": "...", "posts": [...] }
        final List<dynamic> postsJson = data['posts'] ?? [];

        print('✅ Feed recibido: ${postsJson.length} posts');

        // Convertimos cada JSON en un objeto PostModel
        final List<PostModel> posts =
            postsJson.map((json) => PostModel.fromJson(json)).toList();

        // "Emitimos" la lista de posts para que el StreamBuilder la reciba
        yield posts;
      } else {
        print('❌ Error al obtener feed: ${response.statusCode}');
        yield []; // Emitimos lista vacía en caso de error para no colgar la app
      }
    } catch (e) {
      print('❌ Excepción en getPostsStream: $e');
      yield [];
    }
  }

  Future<void> deletePost(String postId) async {
    print("Borrar post no implementado aún en AWS");
  }

  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    print("Likes no implementados aún en AWS");
  }
}
