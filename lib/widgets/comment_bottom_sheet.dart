// lib/widgets/comment_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/comment_model.dart';
import 'package:avivamiento_app/providers/comments_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/widgets/comment_card.dart';
import 'package:avivamiento_app/utils/constants.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final String postId;
  final int initialCommentCount;

  const CommentBottomSheet({
    super.key,
    required this.postId,
    required this.initialCommentCount,
  });

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _replyingToCommentId;
  String? _replyingToAuthorName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(commentsProvider(widget.postId).notifier).loadMore();
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) return;

    final content = _commentController.text.trim();
    _commentController.clear();
    FocusScope.of(context).unfocus();

    // Crear comentario optimista
    final tempComment = CommentModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.postId,
      authorId: currentUser.id,
      authorName: currentUser.nombre,
      authorPhotoUrl: currentUser.fotoUrl,
      authorRole: currentUser.rol,
      content: content,
      timestamp: DateTime.now(),
      parentCommentId: _replyingToCommentId,
    );

    ref.read(commentsProvider(widget.postId).notifier).addComment(tempComment);

    // Limpiar estado de respuesta
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorName = null;
    });

    // Enviar al backend
    try {
      await ref.read(commentServiceProvider).createComment(
            postId: widget.postId,
            authorId: currentUser.id,
            authorName: currentUser.nombre,
            authorPhotoUrl: currentUser.fotoUrl,
            authorRole: currentUser.rol,
            content: content,
            parentCommentId: _replyingToCommentId,
          );

      // Recargar comentarios para obtener el ID real
      await ref.read(commentsProvider(widget.postId).notifier).loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar comentario: $e')),
        );
        // Remover comentario optimista
        ref
            .read(commentsProvider(widget.postId).notifier)
            .removeComment(tempComment.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final currentUser = ref.watch(userProfileProvider).value;

    final canComment =
        currentUser != null && currentUser.rol != AppConstants.roleInvitado;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Lista de comentarios
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error al cargar comentarios: $error'),
              ),
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aún no hay comentarios',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '¡Sé el primero en comentar!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Separar comentarios raíz y respuestas
                final rootComments =
                    comments.where((c) => c.parentCommentId == null).toList();

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: rootComments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final comment = rootComments[index];
                    final replies = comments
                        .where((c) => c.parentCommentId == comment.id)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentCard(
                          comment: comment,
                          onReply: canComment
                              ? () {
                                  setState(() {
                                    _replyingToCommentId = comment.id;
                                    _replyingToAuthorName = comment.authorName;
                                  });
                                  FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  );
                                }
                              : null,
                        ),
                        // Respuestas anidadas
                        if (replies.isNotEmpty)
                          ...replies.map(
                            (reply) => CommentCard(
                              comment: reply,
                              isReply: true,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input de comentario
          if (canComment)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de respuesta
                    if (_replyingToAuthorName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.reply,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Respondiendo a $_replyingToAuthorName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _replyingToCommentId = null;
                                  _replyingToAuthorName = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                    // Campo de texto
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: currentUser.fotoUrl != null
                              ? NetworkImage(currentUser.fotoUrl!)
                              : null,
                          child: currentUser.fotoUrl == null
                              ? const Icon(Icons.person, size: 18)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: _replyingToAuthorName != null
                                  ? 'Escribe tu respuesta...'
                                  : 'Agrega un comentario...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _submitComment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
