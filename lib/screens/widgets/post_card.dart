// lib/screens/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/utils/app_helpers.dart';

/// Un widget que muestra una única publicación en el feed.
/// Inspirado en el diseño de tarjetas de redes sociales.
class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool hasAuthorPhoto =
        post.authorPhotoUrl != null && post.authorPhotoUrl!.isNotEmpty;
    // [NUEVO] Verificamos si la publicación tiene una imagen adjunta.
    final bool hasPostImage =
        post.imageUrl != null && post.imageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip
          .antiAlias, // Importante para que la imagen respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado con la información del autor ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: hasAuthorPhoto
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  child: !hasAuthorPhoto ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            '${post.authorRole} • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: getRoleColor(post.authorRole),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${post.timestamp.toDate().day}/${post.timestamp.toDate().month}/${post.timestamp.toDate().year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Contenido de texto del post ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Text(post.content, style: const TextStyle(fontSize: 16)),
          ),

          // --- [NUEVO] Widget para mostrar la imagen de la publicación ---
          if (hasPostImage)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity, // Ocupa todo el ancho de la tarjeta
                fit: BoxFit.cover,
                // Muestra un indicador de carga mientras la imagen descarga
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                // Muestra un ícono de error si la imagen no se puede cargar
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8), // Un pequeño espacio al final
        ],
      ),
    );
  }
}
