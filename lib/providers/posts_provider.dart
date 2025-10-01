import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Proveedor que expone un Stream de la lista de publicaciones.
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final postService = PostService(firestore);
  return postService.getPostsStream();
});
