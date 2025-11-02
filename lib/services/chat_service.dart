// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _chatCollection;

  ChatService(this._firestore) {
    _chatCollection = _firestore.collection('radio_chat');
  }

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

  /// [MODIFICADO] Envía un nuevo mensaje a la colección.
  Future<void> sendMessage({
    required String text,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl, // [AÑADIDO] Parámetro para la foto
    required String authorRole, // [AÑADIDO] Parámetro para el rol
  }) {
    return _chatCollection.add({
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl, // [AÑADIDO]
      'authorRole': authorRole, // [AÑADIDO]
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
