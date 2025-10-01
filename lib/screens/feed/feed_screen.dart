// lib/screens/feed/feed_screen.dart

import 'package:flutter/material.dart'; // RUTA CORREGIDA
import 'package:flutter_riverpod/flutter_riverpod.dart'; // RUTA CORREGIDA

import 'package:avivamiento_app/providers/posts_provider.dart';
import 'package:avivamiento_app/screens/widgets/post_card.dart'; // RUTA CORREGIDA

/// La pantalla principal que muestra el feed de publicaciones.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el proveedor que nos da la lista de publicaciones.
    final postsAsyncValue = ref.watch(postsProvider);

    // Usamos .when para manejar los estados de carga, error y datos.
    return postsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('No se pudieron cargar las publicaciones: $error'),
      ),
      data: (posts) {
        // Si no hay publicaciones, mostramos un mensaje amigable.
        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay publicaciones.\n¡Vuelve pronto!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          );
        }
        // Si hay datos, construimos una lista de tarjetas de publicación.
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
