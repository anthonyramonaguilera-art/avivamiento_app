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
    XFile? videoFile,
    XFile? audioFile,
  }) async {
    String? imageKey;
    String? videoKey;
    String? audioKey;

    try {
      // 1. Subir imagen (si hay)
      if (imageFile != null) {
        print('📸 Iniciando subida de imagen a S3...');
        final file = File(imageFile.path);
        imageKey = await _uploadService.uploadImageToS3(file);

        if (imageKey == null) {
          throw Exception('Fallo la subida de la imagen a S3');
        }
        print('✅ Imagen subida. Key: $imageKey');
      }

      // 2. Subir video (si hay)
      if (videoFile != null) {
        print('🎬 Iniciando subida de video a S3...');
        final file = File(videoFile.path);
        videoKey = await _uploadService.uploadVideoToS3(file);

        if (videoKey == null) {
          throw Exception('Falló la subida del video a S3');
        }
        print('✅ Video subido. Key: $videoKey');
      }

      // 3. Subir audio (si hay)
      if (audioFile != null) {
        print('🎵 Iniciando subida de audio a S3...');
        final file = File(audioFile.path);
        audioKey = await _uploadService.uploadAudioToS3(file);

        if (audioKey == null) {
          throw Exception('Falló la subida del audio a S3');
        }
        print('✅ Audio subido. Key: $audioKey');
      }

      // 4. Enviar metadatos a Lambda
      final url = Uri.parse('$_apiBaseUrl/create-post');

      final body = {
        "userId": authorId,
        "authorName": authorName,
        "content": content,
        if (imageKey != null) "imageKey": imageKey,
        if (videoKey != null) "videoKey": videoKey,
        if (audioKey != null) "audioKey": audioKey,
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

  /// Obtener posts con paginación para infinite scroll
  Future<List<PostModel>> getPosts({
    String? lastPostId,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (lastPostId != null) 'lastPostId': lastPostId,
      };

      final url =
          Uri.parse('$_apiBaseUrl/feed').replace(queryParameters: queryParams);

      print('📥 Solicitando feed a: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> postsJson = data['posts'] ?? [];

        print('✅ Feed recibido: ${postsJson.length} posts');

        final List<PostModel> posts =
            postsJson.map((json) => PostModel.fromJson(json)).toList();

        return posts;
      } else {
        print('❌ Error al obtener feed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Excepción en getPosts: $e');
      return [];
    }
  }

  /// Compartir una publicación (incrementa el contador)
  Future<void> sharePost(String postId, String userId) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/share-post');

      final body = {
        "postId": postId,
        "userId": userId,
      };

      print('🔗 Compartiendo post: $postId');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al compartir: ${response.body}');
      }

      print('✅ Post compartido exitosamente');
    } catch (e) {
      print('❌ Error en sharePost: $e');
      rethrow;
    }
  }

  /// Eliminar una publicación
  Future<void> deletePost(String postId) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/delete-post');

      final body = {"postId": postId};

      print('🗑️ Eliminando post: $postId');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar: ${response.body}');
      }

      print('✅ Post eliminado exitosamente');
    } catch (e) {
      print('❌ Error en deletePost: $e');
      rethrow;
    }
  }

  /// Toggle like en una publicación
  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/post-like');

      final body = {
        "postId": postId,
        "userId": userId,
        "action": isLiked ? "unlike" : "like",
      };

      print('💙 Toggle like: $postId');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al dar like: ${response.body}');
      }

      print('✅ Like actualizado');
    } catch (e) {
      print('❌ Error en toggleLike: $e');
      rethrow;
    }
  }
}
