// lib/screens/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // [NUEVO] Lógica para determinar si hay una URL de foto válida.
    final bool hasPhoto =
        post.authorPhotoUrl != null && post.authorPhotoUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // [MODIFICADO] El CircleAvatar ahora es dinámico.
                CircleAvatar(
                  // Si hay foto, usa NetworkImage.
                  backgroundImage: hasPhoto
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
                  // Si no hay foto, muestra el ícono de persona.
                  child: !hasPhoto ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // [AÑADIDO] Mostramos el rol del autor.
                    Text(
                      post.authorRole,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
