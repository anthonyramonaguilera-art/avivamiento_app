// lib/screens/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/utils/app_helpers.dart'; // <-- 1. IMPORTA EL HELPER

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  backgroundImage: hasPhoto
                      ? NetworkImage(post.authorPhotoUrl!)
                      : null,
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
                    Row(
                      children: [
                        // --- 2. APLICA EL COLOR AL ROL ---
                        Text(
                          '${post.authorRole} • ',
                          style: TextStyle(
                            fontSize: Theme.of(
                              context,
                            ).textTheme.bodySmall?.fontSize,
                            color: getRoleColor(
                              post.authorRole,
                            ), // <-- USA LA FUNCIÓN
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // --- 3. MUESTRA LA FECHA ---
                        Text(
                          '${post.timestamp.toDate().day}/${post.timestamp.toDate().month}/${post.timestamp.toDate().year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
