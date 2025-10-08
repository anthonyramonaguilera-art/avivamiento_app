// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;

  // [AÑADIDO] Un campo para guardar la URL de la foto del autor.
  // Es opcional (puede ser nulo) por si un usuario no tiene foto.
  final String? authorPhotoUrl;

  // [AÑADIDO] Un campo para guardar el rol del autor.
  final String authorRole;

  final String content;
  final String? imageUrl;
  final Timestamp timestamp;
  final int likes;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl, // [AÑADIDO] Lo agregamos al constructor.
    required this.authorRole, // [AÑADIDO] Lo agregamos al constructor.
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0,
  });

  /// Factory para crear un PostModel desde los datos de Firestore.
  factory PostModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PostModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Autor Desconocido',

      // [AÑADIDO] Leemos el nuevo campo desde la base de datos.
      authorPhotoUrl: data['authorPhotoUrl'],

      // [AÑADIDO] Leemos el rol. Si no existe, le asignamos 'Miembro' por defecto.
      authorRole: data['authorRole'] ?? 'Miembro',

      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
    );
  }
}
