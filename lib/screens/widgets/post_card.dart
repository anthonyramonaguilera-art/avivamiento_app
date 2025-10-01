// lib/screens/feed/widgets/post_card.dart

import 'package:flutter/material.dart'; // RUTA CORREGIDA
import 'package:avivamiento_app/models/post_model.dart'; // RUTA CORREGIDA

/// Un widget que muestra una única publicación en un formato de tarjeta.
/// Es un [StatelessWidget] porque solo muestra datos y no gestiona estado interno.
class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con el nombre del autor y la fecha.
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ), // Placeholder para la foto del autor
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      // Formateamos la fecha para que sea legible.
                      '${post.timestamp.toDate().day}/${post.timestamp.toDate().month}/${post.timestamp.toDate().year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contenido de la publicación.
            Text(post.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
