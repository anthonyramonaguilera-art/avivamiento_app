import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

/// Provider para la instancia de AudioPlayer
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

/// Provider para el estado del reproductor
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.onPlayerStateChanged;
});
