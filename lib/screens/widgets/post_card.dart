// lib/screens/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/utils/app_helpers.dart';
import 'package:avivamiento_app/utils/constants.dart';
import 'package:avivamiento_app/screens/livestreams/video_player_screen.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Variables y Lógica de Permisos ---
    final UserModel? currentUser = ref.watch(userProfileProvider).value;

    final hasAuthorPhoto =
        post.authorPhotoUrl != null && post.authorPhotoUrl!.isNotEmpty;
    final hasPostImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasVideo = post.videoUrl != null && post.videoUrl!.isNotEmpty;

    final bool canDelete = currentUser != null &&
        (post.authorId == currentUser.id ||
            currentUser.rol == AppConstants.rolePastor ||
            currentUser.rol == AppConstants.roleAdmin);

    final bool isLiked =
        currentUser != null && post.likedBy.contains(currentUser.id);
    final bool canLike =
        currentUser != null && currentUser.rol != AppConstants.roleInvitado;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado del Post ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 4.0, 0),
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
                      Text(post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text('${post.authorRole} • ',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: getRoleColor(post.authorRole),
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '${post.timestamp.toDate().day}/${post.timestamp.toDate().month}/${post.timestamp.toDate().year}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  _PostOptionsMenu(
                    // Usamos el sub-widget
                    onDelete: () =>
                        _showDeleteConfirmation(context, ref, post.id),
                  ),
              ],
            ),
          ),

          // --- Contenido del Post ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(post.content, style: const TextStyle(fontSize: 16)),
          ),

          // --- Imagen o Video ---
          if (hasPostImage)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator())),
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Icon(Icons.error, color: Colors.red))),
              ),
            )
          else if (hasVideo)
            _VideoThumbnail(post: post), // Usamos el sub-widget

          const Divider(height: 1),

          // --- Barra de Likes ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${post.likes} Me gusta',
                    style: const TextStyle(color: Colors.grey)),
                TextButton.icon(
                  onPressed: canLike
                      ? () => ref
                          .read(postServiceProvider)
                          .toggleLike(post.id, currentUser!.id, isLiked)
                      : null,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    'Me gusta',
                    style: TextStyle(color: isLiked ? Colors.red : Colors.grey),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- [NUEVA ESTRUCTURA] Widgets y Funciones Auxiliares EXTERNAS a la clase ---

/// Menú de opciones para una publicación (Eliminar, Editar, etc.)
class _PostOptionsMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const _PostOptionsMenu({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Eliminar'),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar la miniatura de un video.
class _VideoThumbnail extends StatelessWidget {
  final PostModel post;

  const _VideoThumbnail({required this.post});

  String? _getYoutubeVideoId(String url) {
    if (!url.contains("youtube.com/") && !url.contains("youtu.be/"))
      return null;
    if (url.contains("youtu.be/"))
      return url.split("youtu.be/").last.split("?").first;
    return url.split("v=").last.split("&").first;
  }

  @override
  Widget build(BuildContext context) {
    String? thumbnailUrl;
    if (post.videoProvider == 'YouTube' && post.videoUrl != null) {
      final videoId = _getYoutubeVideoId(post.videoUrl!);
      if (videoId != null) {
        thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    }

    return GestureDetector(
      onTap: () {
        if (post.videoUrl != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              // [SOLUCIÓN A TU ERROR]
              // 1. Quitamos 'const' porque 'post.content' no es una constante.
              // 2. Añadimos el parámetro 'title' que es requerido.
              builder: (context) => VideoPlayerScreen(
                videoUrl: post.videoUrl!,
                title:
                    post.authorName, // Usamos el nombre del autor como título
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8.0),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: thumbnailUrl != null
              ? DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.darken),
                )
              : null,
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
        ),
      ),
    );
  }
}

/// Muestra un diálogo de confirmación para eliminar una publicación.
void _showDeleteConfirmation(
    BuildContext context, WidgetRef ref, String postId) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar Eliminación'),
      content:
          const Text('¿Estás seguro de que quieres eliminar esta publicación?'),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        TextButton(
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          onPressed: () async {
            Navigator.of(ctx).pop();
            try {
              await ref.read(postServiceProvider).deletePost(postId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Publicación eliminada')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}
