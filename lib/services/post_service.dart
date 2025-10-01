// lib/services/post_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _postsCollection;

  PostService(this._firestore) {
    _postsCollection = _firestore.collection('posts');
  }

  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// **[NUEVO]** Crea un nuevo documento de publicación en Firestore.
  Future<void> createPost({
    required String content,
    required String authorId,
    required String authorName,
  }) {
    return _postsCollection.add({
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': FieldValue.serverTimestamp(), // Usamos la hora del servidor
      'likes': 0,
    });
  }
}
