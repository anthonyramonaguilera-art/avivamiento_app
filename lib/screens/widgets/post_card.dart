// lib/screens/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/posts_provider.dart';
import 'package:avivamiento_app/utils/app_helpers.dart';
import 'package:avivamiento_app/utils/constants.dart';
import 'package:avivamiento_app/screens/livestreams/video_player_screen.dart';
import 'package:avivamiento_app/widgets/comment_bottom_sheet.dart';
import 'package:avivamiento_app/widgets/media_player_widget.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLike(UserModel currentUser) async {
    final isLiked = widget.post.likedBy.contains(currentUser.id);

    // Animación del corazón
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    try {
      await ref.read(postServiceProvider).toggleLike(
            widget.post.id,
            currentUser.id,
            isLiked,
          );

      // Refrescar feed
      await ref.read(postsProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al dar like: $e')),
        );
      }
    }
  }

  Future<void> _handleShare() async {
    try {
      final currentUser = ref.read(userProfileProvider).value;

      final shareText = '''
📖 ${widget.post.content}

👤 Compartido por: ${widget.post.authorName}
✝️ Avivamiento CIV
''';

      await Share.share(shareText);

      // Incrementar contador de shares en el backend
      if (currentUser != null) {
        await ref
            .read(postServiceProvider)
            .sharePost(widget.post.id, currentUser.id);
      }
    } catch (e) {
      print('Error al compartir: $e');
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(
        postId: widget.post.id,
        initialCommentCount: widget.post.commentCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? currentUser = ref.watch(userProfileProvider).value;

    final hasAuthorPhoto = widget.post.authorPhotoUrl != null &&
        widget.post.authorPhotoUrl!.isNotEmpty;
    final hasPostImage =
        widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;
    final hasVideo =
        widget.post.videoUrl != null && widget.post.videoUrl!.isNotEmpty;
    final hasAudio =
        widget.post.audioUrl != null && widget.post.audioUrl!.isNotEmpty;

    final bool canDelete = currentUser != null &&
        (widget.post.authorId == currentUser.id ||
            currentUser.rol == AppConstants.rolePastor ||
            currentUser.rol == AppConstants.roleAdmin);

    final bool isLiked =
        currentUser != null && widget.post.likedBy.contains(currentUser.id);

    final bool canLike =
        currentUser != null && currentUser.rol != AppConstants.roleInvitado;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado Mejorado ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
            child: Row(
              children: [
                // Avatar con sombra
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: hasAuthorPhoto
                        ? NetworkImage(widget.post.authorPhotoUrl!)
                        : null,
                    child: !hasAuthorPhoto
                        ? const Icon(Icons.person, size: 24)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          // Badge de rol con diseño mejorado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  getRoleColor(widget.post.authorRole),
                                  getRoleColor(widget.post.authorRole)
                                      .withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.post.authorRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${_formatTimestamp(widget.post.timestamp)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canDelete)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // --- Contenido del Post ---
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.post.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),

          // --- Media (Imagen, Video o Audio) ---
          if (hasPostImage)
            _buildImageWidget()
          else if (hasVideo)
            _buildVideoWidget()
          else if (hasAudio)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AudioPlayerWidget(audioUrl: widget.post.audioUrl!),
            ),

          // --- Barra de Estadísticas ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Row(
              children: [
                if (widget.post.likes > 0) ...[
                  const Icon(Icons.favorite, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.post.likes}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
                const Spacer(),
                if (widget.post.commentCount > 0)
                  Text(
                    '${widget.post.commentCount} comentario${widget.post.commentCount != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                if (widget.post.shareCount > 0) ...[
                  if (widget.post.commentCount > 0)
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${widget.post.shareCount} compartido${widget.post.shareCount != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // --- Botones de Acción Mejorados ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón de Like con animación
                Expanded(
                  child: TextButton.icon(
                    onPressed: canLike ? () => _handleLike(currentUser!) : null,
                    icon: AnimatedBuilder(
                      animation: _likeScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _likeScaleAnimation.value,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    label: Text(
                      'Me gusta',
                      style: TextStyle(
                        color: isLiked ? Colors.red : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Botón de Comentar
                Expanded(
                  child: TextButton.icon(
                    onPressed: _openComments,
                    icon: Icon(Icons.comment_outlined,
                        color: Colors.grey[700], size: 20),
                    label: Text(
                      'Comentar',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Botón de Compartir
                Expanded(
                  child: TextButton.icon(
                    onPressed: _handleShare,
                    icon: Icon(Icons.share_outlined,
                        color: Colors.grey[700], size: 20),
                    label: Text(
                      'Compartir',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    return GestureDetector(
      onTap: () {
        // Podría abrir en pantalla completa
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Image.network(
          widget.post.imageUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget() {
    String? thumbnailUrl;
    if (widget.post.videoProvider == 'YouTube' &&
        widget.post.videoUrl != null) {
      final videoId = _getYoutubeVideoId(widget.post.videoUrl!);
      if (videoId != null) {
        thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      }
    }

    return GestureDetector(
      onTap: () {
        if (widget.post.videoUrl != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoUrl: widget.post.videoUrl!,
                title: widget.post.authorName,
              ),
            ),
          );
        }
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          image: thumbnailUrl != null
              ? DecorationImage(
                  image: NetworkImage(thumbnailUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 72,
          ),
        ),
      ),
    );
  }

  String? _getYoutubeVideoId(String url) {
    if (!url.contains("youtube.com/") && !url.contains("youtu.be/")) {
      return null;
    }
    if (url.contains("youtu.be/")) {
      return url.split("youtu.be/").last.split("?").first;
    }
    return url.split("v=").last.split("&").first;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta publicación?',
        ),
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
                await ref.read(postServiceProvider).deletePost(widget.post.id);
                await ref.read(postsProvider.notifier).refresh();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada')),
                  );
                }
              } catch (e) {
                if (mounted) {
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
}
