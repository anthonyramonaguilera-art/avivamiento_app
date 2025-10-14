// lib/providers/posts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que expone la lista de publicaciones en tiempo real.
///
/// Este provider observa el `postServiceProvider` para obtener el flujo de datos.
/// Cualquier widget que escuche a `postsProvider` se reconstruirá automáticamente
/// cuando haya nuevos posts, actualizaciones o eliminaciones en Firestore.
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  // [CORRECCIÓN] Ahora leemos el 'postServiceProvider' que ya está configurado
  // con ambas dependencias (Firestore y Storage).
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream();
});
