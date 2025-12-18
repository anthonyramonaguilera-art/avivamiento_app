// lib/services/comment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:avivamiento_app/models/comment_model.dart';

/// Servicio para gestionar comentarios en publicaciones
class CommentService {
  final String _apiBaseUrl =
      'https://kw64z1i0pk.execute-api.us-east-1.amazonaws.com';

  /// Crear un nuevo comentario
  Future<void> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String authorRole,
    required String content,
    String? parentCommentId, // Para respuestas anidadas
  }) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/create-comment');

      final body = {
        "postId": postId,
        "userId": authorId,
        "authorName": authorName,
        "authorPhotoUrl": authorPhotoUrl,
        "authorRole": authorRole,
        "content": content,
        if (parentCommentId != null) "parentCommentId": parentCommentId,
      };

      print('🚀 Creando comentario: $url');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('📡 Respuesta crear comentario: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Error al crear comentario: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en createComment: $e');
      rethrow;
    }
  }

  /// Obtener comentarios de una publicación (con paginación)
  Future<List<CommentModel>> getComments({
    required String postId,
    String? lastCommentId,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (lastCommentId != null) 'lastCommentId': lastCommentId,
      };

      final url = Uri.parse('$_apiBaseUrl/comments/$postId')
          .replace(queryParameters: queryParams);

      print('📥 Obteniendo comentarios: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentsJson = data['comments'] ?? [];

        print('✅ Comentarios recibidos: ${commentsJson.length}');

        return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        print('❌ Error al obtener comentarios: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Excepción en getComments: $e');
      return [];
    }
  }

  /// Obtener respuestas de un comentario específico
  Future<List<CommentModel>> getReplies({
    required String commentId,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/comments/$commentId/replies')
          .replace(queryParameters: {'limit': limit.toString()});

      print('📥 Obteniendo respuestas: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> repliesJson = data['replies'] ?? [];

        return repliesJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Excepción en getReplies: $e');
      return [];
    }
  }

  /// Toggle like en un comentario
  Future<void> toggleLike({
    required String commentId,
    required String userId,
    required bool isLiked,
  }) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/comment-like');

      final body = {
        "commentId": commentId,
        "userId": userId,
        "action": isLiked ? "unlike" : "like",
      };

      print('💙 Toggle like comentario: $commentId');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al dar like: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en toggleLike: $e');
      rethrow;
    }
  }

  /// Eliminar un comentario
  Future<void> deleteComment(String commentId) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/delete-comment');

      final body = {"commentId": commentId};

      print('🗑️ Eliminando comentario: $commentId');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar comentario: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en deleteComment: $e');
      rethrow;
    }
  }
}
