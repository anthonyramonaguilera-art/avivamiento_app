// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para una publicación en el feed.
///
/// Cada instancia corresponde a un documento en la colección 'posts' de Firestore.
/// Es inmutable para asegurar un estado consistente.
class PostModel {
  /// El ID único del documento de la publicación.
  final String id;

  /// El ID del autor (corresponde al UID del UserModel).
  final String authorId;

  /// El nombre del autor para mostrarlo directamente en la UI.
  final String authorName;

  /// El contenido de texto de la publicación.
  final String content;

  /// La URL de una imagen asociada (opcional).
  final String? imageUrl;

  /// La fecha y hora de creación de la publicación.
  final Timestamp timestamp;

  /// Un contador de "me gusta" (para futuras funcionalidades).
  final int likes;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likes = 0, // Valor por defecto para los 'me gusta'.
  });

  /// Factory constructor para crear una instancia de [PostModel] desde un mapa de Firestore.
  ///
  /// Esencial para convertir los datos leídos de la base de datos a un objeto Dart.
  factory PostModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PostModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Autor Desconocido',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
    );
  }
}
