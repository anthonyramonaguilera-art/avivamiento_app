// lib/providers/youtube_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/youtube_video_model.dart';
import 'package:avivamiento_app/services/youtube_service.dart';

/// Provider del servicio de YouTube
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService();
});

/// Provider para obtener videos largos del canal (Predicas)
final youtubeVideosProvider =
    FutureProvider<List<YouTubeVideoModel>>((ref) async {
  final youtubeService = ref.watch(youtubeServiceProvider);
  return await youtubeService.getChannelVideos(maxResults: 50);
});

/// Provider para obtener Shorts del canal (Clips)
final youtubeShortsProvider =
    FutureProvider<List<YouTubeVideoModel>>((ref) async {
  final youtubeService = ref.watch(youtubeServiceProvider);
  return await youtubeService.getChannelShorts(maxResults: 50);
});

/// Provider para el estado del tab actual (0 = Predicas, 1 = Clips)
final selectedVideoTabProvider = StateProvider<int>((ref) => 0);
