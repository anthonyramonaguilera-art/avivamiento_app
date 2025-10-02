// lib/models/chat_message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para un único mensaje en el chat de la radio.
class ChatMessageModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final Timestamp timestamp;

  ChatMessageModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  /// Factory para crear una instancia desde un mapa de Firestore.
  factory ChatMessageModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ChatMessageModel(
      id: documentId,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anónimo',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
