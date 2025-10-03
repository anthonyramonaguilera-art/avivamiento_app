// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/posts_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/screens/feed/create_post_screen.dart';
import 'package:avivamiento_app/screens/widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(postsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final bool isAdmin = userProfile.when(
      data: (user) => user?.rol == 'Pastor' || user?.rol == 'Líder',
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      body: postsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('No se pudieron cargar las publicaciones: $error'),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'Aún no hay publicaciones.\n¡Vuelve pronto!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              // [CORRECCIÓN] Añadimos un tag único para el Hero
              heroTag: 'add_post_button',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
