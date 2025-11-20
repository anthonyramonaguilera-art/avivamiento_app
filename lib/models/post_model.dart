// lib/models/post_model.dart

// [CAMBIO] Ya no necesitamos cloud_firestore. El modelo es puro Dart.
// import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final String content;
  final String? imageUrl;

  // Campos de video (opcionales por ahora en AWS)
  final String? videoUrl;
  final String? videoProvider;

  // [CAMBIO] Usamos DateTime nativo en lugar de Timestamp de Firebase
  final DateTime timestamp;

  final int likes;
  final List<String> likedBy;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorRole,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.videoProvider,
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> data) {
    // DynamoDB devuelve las fechas como Strings ISO 8601 (ej: "2025-11-19T...")
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is String) {
        return DateTime.parse(dateVal);
      }
      return DateTime.now(); // Fallback por seguridad
    }

    // Extraemos el ID. En DynamoDB Single Table, el ID suele venir en el campo "PK"
    // o en "postId" si lo devolvimos limpio.
    // Asumimos que la Lambda nos manda una lista limpia de objetos "Post".
    // Si la Lambda devuelve el raw de Dynamo, el ID es 'PK' (ej: "POST#uuid").
    String docId = data['postId'] ?? data['PK'] ?? '';
    if (docId.startsWith('POST#')) {
      docId = docId.replaceAll('POST#', ''); // Limpiamos el prefijo si existe
    }

    return PostModel(
      id: docId,
      authorId: data['userId'] ??
          data['authorId'] ??
          '', // AWS usa 'userId', mantenemos compatibilidad
      authorName: data['authorName'] ?? 'Autor',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'Miembro',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ??
          data[
              'imageKey'], // A veces lo guardamos como imageKey, mapeamos ambos
      videoUrl: data['videoUrl'],
      videoProvider: data['videoProvider'],
      // [CAMBIO] Parseamos el string ISO a DateTime
      timestamp: parseDate(data['createdAt'] ?? data['timestamp']),
      likes: (data['likes'] is int) ? data['likes'] : 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}
