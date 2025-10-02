// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  // Creamos una referencia a la colección del chat, ordenada por fecha.
  late final CollectionReference<Map<String, dynamic>> _chatCollection;

  ChatService(this._firestore) {
    _chatCollection = _firestore.collection('radio_chat');
  }

  /// Obtiene un Stream con la lista de mensajes del chat.
  /// Usamos `limit(50)` para no cargar mensajes muy antiguos y mantener la app fluida.
  Stream<List<ChatMessageModel>> getChatMessagesStream() {
    return _chatCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessageModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Envía un nuevo mensaje a la colección.
  Future<void> sendMessage({
    required String text,
    required String authorId,
    required String authorName,
  }) {
    return _chatCollection.add({
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
