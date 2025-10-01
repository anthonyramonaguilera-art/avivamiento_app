// lib/services/post_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/post_model.dart';

/// Servicio para manejar las operaciones CRUD (Crear, Leer, Actualizar, Borrar) de las publicaciones.
class PostService {
  final FirebaseFirestore _firestore;
  // Referencia a la colección 'posts'. Se ordena por fecha de forma descendente.
  late final CollectionReference<Map<String, dynamic>> _postsCollection;

  PostService(this._firestore) {
    _postsCollection = _firestore.collection('posts');
  }

  /// Obtiene un Stream de la lista de publicaciones.
  ///
  /// Usar un Stream permite que la UI se actualice automáticamente cuando se
  /// añadan, modifiquen o eliminen publicaciones en Firestore.
  /// Los posts se ordenan por 'timestamp' para mostrar los más recientes primero.
  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          // Mapea cada documento de la colección a un objeto PostModel.
          return snapshot.docs.map((doc) {
            return PostModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
