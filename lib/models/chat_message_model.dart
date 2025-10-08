// lib/models/chat_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String authorId;
  final String authorName;

  // [AÑADIDO] Campo para la URL de la foto.
  final String? authorPhotoUrl;

  // [AÑADIDO] Campo para el rol.
  final String authorRole;

  final String text;
  final Timestamp timestamp;

  ChatMessageModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl, // [AÑADIDO]
    required this.authorRole, // [AÑADIDO]
    required this.text,
    required this.timestamp,
  });

  /// Factory para crear un ChatMessageModel desde Firestore.
  factory ChatMessageModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ChatMessageModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anónimo',

      // [AÑADIDO] Leemos los nuevos campos de la base de datos.
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'] ?? 'Miembro',

      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
