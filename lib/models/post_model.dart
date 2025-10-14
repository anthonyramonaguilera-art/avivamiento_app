// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para una publicación en el feed.
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final String content;

  /// [NUEVO] La URL de la imagen adjunta a la publicación, si existe.
  final String? imageUrl;

  final Timestamp timestamp;
  final int likes;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.authorRole,
    required this.content,
    this.imageUrl, // Se añade al constructor
    required this.timestamp,
    this.likes = 0,
  });

  /// Factory para crear un PostModel desde los datos de Firestore.
  factory PostModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PostModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Autor Desconocido',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'Miembro',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'], // Se lee el nuevo campo
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
    );
  }
}
