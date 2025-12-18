// lib/providers/posts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Provider para gestionar el estado de los posts con paginación
class PostsNotifier extends StateNotifier<AsyncValue<List<PostModel>>> {
  final PostService _postService;

  List<PostModel> _allPosts = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _lastPostId;

  PostsNotifier(this._postService) : super(const AsyncValue.loading()) {
    loadInitialPosts();
  }

  /// Cargar posts iniciales
  Future<void> loadInitialPosts() async {
    try {
      state = const AsyncValue.loading();
      final posts = await _postService.getPosts(limit: 10);

      _allPosts = posts;
      _hasMore = posts.length >= 10;
      _lastPostId = posts.isNotEmpty ? posts.last.id : null;

      state = AsyncValue.data(posts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cargar más posts (infinite scroll)
  Future<void> loadMorePosts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;

    try {
      final newPosts = await _postService.getPosts(
        lastPostId: _lastPostId,
        limit: 10,
      );

      if (newPosts.isNotEmpty) {
        _allPosts = [..._allPosts, ...newPosts];
        _lastPostId = newPosts.last.id;
        _hasMore = newPosts.length >= 10;
        state = AsyncValue.data(_allPosts);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error cargando más posts: $e');
      // No cambiamos el estado para no perturbar la lista actual
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh manual (pull to refresh)
  Future<void> refresh() async {
    _lastPostId = null;
    _hasMore = true;
    await loadInitialPosts();
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}

/// Provider principal de posts
final postsProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<PostModel>>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return PostsNotifier(postService);
});
