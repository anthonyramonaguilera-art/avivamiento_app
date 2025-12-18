// lib/widgets/comment_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/comment_model.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/comments_provider.dart';
import 'package:avivamiento_app/utils/app_helpers.dart';
import 'package:avivamiento_app/utils/constants.dart';

class CommentCard extends ConsumerStatefulWidget {
  final CommentModel comment;
  final VoidCallback? onReply;
  final bool isReply; // Si es una respuesta anidada

  const CommentCard({
    super.key,
    required this.comment,
    this.onReply,
    this.isReply = false,
  });

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
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

  Future<void> _handleLike() async {
    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) return;

    final isLiked = widget.comment.likedBy.contains(currentUser.id);

    // Optimistic update
    final updatedComment = widget.comment.copyWith(
      likes: isLiked ? widget.comment.likes - 1 : widget.comment.likes + 1,
      likedBy: isLiked
          ? widget.comment.likedBy.where((id) => id != currentUser.id).toList()
          : [...widget.comment.likedBy, currentUser.id],
    );

    ref
        .read(commentsProvider(widget.comment.postId).notifier)
        .updateComment(widget.comment.id, updatedComment);

    // Animación
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Llamada al backend
    try {
      await ref.read(commentServiceProvider).toggleLike(
            commentId: widget.comment.id,
            userId: currentUser.id,
            isLiked: isLiked,
          );
    } catch (e) {
      // Revertir en caso de error
      ref
          .read(commentsProvider(widget.comment.postId).notifier)
          .updateComment(widget.comment.id, widget.comment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al dar like: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este comentario?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(commentServiceProvider).deleteComment(widget.comment.id);
        ref
            .read(commentsProvider(widget.comment.postId).notifier)
            .removeComment(widget.comment.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comentario eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProfileProvider).value;
    final isLiked =
        currentUser != null && widget.comment.likedBy.contains(currentUser.id);

    final canDelete = currentUser != null &&
        (widget.comment.authorId == currentUser.id ||
            currentUser.rol == AppConstants.rolePastor ||
            currentUser.rol == AppConstants.roleAdmin);

    final hasPhoto = widget.comment.authorPhotoUrl != null &&
        widget.comment.authorPhotoUrl!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(
        left: widget.isReply ? 48.0 : 0,
        bottom: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: widget.isReply ? 16 : 20,
            backgroundImage:
                hasPhoto ? NetworkImage(widget.comment.authorPhotoUrl!) : null,
            child: !hasPhoto
                ? Icon(Icons.person, size: widget.isReply ? 16 : 20)
                : null,
          ),
          const SizedBox(width: 12),

          // Contenido del comentario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con nombre, rol y opciones
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            widget.comment.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: getRoleColor(widget.comment.authorRole)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: getRoleColor(widget.comment.authorRole),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.comment.authorRole,
                              style: TextStyle(
                                fontSize: 10,
                                color: getRoleColor(widget.comment.authorRole),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimestamp(widget.comment.timestamp),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canDelete)
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onPressed: _handleDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Contenido del comentario
                Text(
                  widget.comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Acciones: Like y Responder
                Row(
                  children: [
                    // Botón de like con animación
                    InkWell(
                      onTap: currentUser != null ? _handleLike : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _likeAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _likeAnimation.value,
                                  child: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 16,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                );
                              },
                            ),
                            if (widget.comment.likes > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${widget.comment.likes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLiked ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Botón de responder (solo en comentarios raíz)
                    if (!widget.isReply && widget.onReply != null)
                      InkWell(
                        onTap: widget.onReply,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.reply, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Responder',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
