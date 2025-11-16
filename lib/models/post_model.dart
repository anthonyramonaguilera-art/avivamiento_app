// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String authorRole;
  final String content;
  final String? imageUrl;

  // --- [SOLUCIÓN] Campos añadidos para el video ---
  final String? videoUrl;
  final String? videoProvider;

  final Timestamp timestamp;
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
    this.videoUrl, // <-- Incluido en el constructor
    this.videoProvider, // <-- Incluido en el constructor
    required this.timestamp,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String documentId) {
    final List<dynamic> likedByFromDb = data['likedBy'] ?? [];
    final List<String> likedByList = List<String>.from(likedByFromDb);

    return PostModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Autor Desconocido',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'Miembro',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'], // <-- Mapeado desde Firestore
      videoProvider: data['videoProvider'], // <-- Mapeado desde Firestore
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
      likedBy: likedByList,
    );
  }
}
