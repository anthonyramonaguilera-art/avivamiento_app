// lib/providers/comments_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/comment_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/services/comment_service.dart';

/// Provider para gestionar comentarios de un post específico
class CommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final CommentService _commentService;
  final String postId;

  List<CommentModel> _allComments = [];
  bool _hasMore = true;
  String? _lastCommentId;

  CommentsNotifier(this._commentService, this.postId)
      : super(const AsyncValue.loading()) {
    loadComments();
  }

  /// Cargar comentarios iniciales
  Future<void> loadComments() async {
    try {
      state = const AsyncValue.loading();
      final comments = await _commentService.getComments(
        postId: postId,
        limit: 20,
      );

      _allComments = comments;
      _hasMore = comments.length >= 20;
      _lastCommentId = comments.isNotEmpty ? comments.last.id : null;

      state = AsyncValue.data(comments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cargar más comentarios
  Future<void> loadMore() async {
    if (!_hasMore) return;

    try {
      final newComments = await _commentService.getComments(
        postId: postId,
        lastCommentId: _lastCommentId,
        limit: 20,
      );

      if (newComments.isNotEmpty) {
        _allComments = [..._allComments, ...newComments];
        _lastCommentId = newComments.last.id;
        _hasMore = newComments.length >= 20;
        state = AsyncValue.data(_allComments);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error cargando más comentarios: $e');
    }
  }

  /// Agregar un nuevo comentario a la lista local (optimistic update)
  void addComment(CommentModel comment) {
    _allComments = [comment, ..._allComments];
    state = AsyncValue.data(_allComments);
  }

  /// Actualizar un comentario (ej: después de dar like)
  void updateComment(String commentId, CommentModel updatedComment) {
    _allComments = _allComments.map((c) {
      return c.id == commentId ? updatedComment : c;
    }).toList();
    state = AsyncValue.data(_allComments);
  }

  /// Eliminar un comentario
  void removeComment(String commentId) {
    _allComments = _allComments.where((c) => c.id != commentId).toList();
    state = AsyncValue.data(_allComments);
  }

  bool get hasMore => _hasMore;
}

/// Family provider para comentarios por post
final commentsProvider = StateNotifierProvider.family<CommentsNotifier,
    AsyncValue<List<CommentModel>>, String>((ref, postId) {
  final commentService = ref.watch(commentServiceProvider);
  return CommentsNotifier(commentService, postId);
});
