// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

// Provider para gestionar la instancia de nuestro reproductor de audio.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  // Nos aseguramos de liberar los recursos cuando el provider sea destruido.
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});

  // ** [CÓDIGO ACTUALIZADO] **
  // Aquí está la URL real del streaming de la radio.
  final String streamUrl = 'https://stream.zeno.fm/9vrkfkz49ehvv';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final isPlaying = playerStateAsync.maybeWhen(
      data: (state) => state == PlayerState.playing,
      orElse: () => false,
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radio, size: 120, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Radio Avivamiento En Vivo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 80,
                color: Colors.blue,
              ),
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.play(UrlSource(streamUrl));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Un StreamProvider que nos informa sobre el estado del reproductor en tiempo real.
final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  return audioPlayer.onPlayerStateChanged;
});
