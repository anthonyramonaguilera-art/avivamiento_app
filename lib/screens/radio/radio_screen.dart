// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/audio_provider.dart';
import 'package:avivamiento_app/providers/chat_provider.dart';
import 'package:avivamiento_app/screens/radio/widgets/chat_bubble.dart';
import 'package:avivamiento_app/screens/radio/widgets/message_input_field.dart';

// --- [NUEVO] Provider para el estado del volumen ---
/// Mantiene el estado del volumen del reproductor de la radio.
///
/// El valor va de 0.0 (silencio) a 1.0 (máximo).
/// El valor inicial es 1.0.
final volumeProvider = StateProvider<double>((ref) => 1.0);

class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});
  final String streamUrl = 'https://stream.zeno.fm/9vrkfkz49ehvv';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Observamos los providers que necesitamos ---
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final currentVolume = ref.watch(
      volumeProvider,
    ); // El valor actual del slider
    final messagesAsyncValue = ref.watch(chatMessagesProvider);
    final userProfile = ref.watch(userProfileProvider);

    final isPlaying = playerStateAsync.maybeWhen(
      data: (state) => state == PlayerState.playing,
      orElse: () => false,
    );
    final bool canChat =
        userProfile.value != null && userProfile.value?.rol != 'Invitado';

    return Scaffold(
      body: Column(
        children: [
          // --- SECCIÓN DEL REPRODUCTOR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20.0,
              20.0,
              20.0,
              10.0,
            ), // Reducimos padding inferior
            child: Column(
              children: [
                const Icon(Icons.radio, size: 100, color: Colors.blue),
                const SizedBox(height: 10),
                const Text(
                  'Radio Avivamiento En Vivo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 70,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    } else {
                      await audioPlayer.setVolume(
                        currentVolume,
                      ); // Asegura el volumen al iniciar
                      await audioPlayer.play(UrlSource(streamUrl));
                    }
                  },
                ),

                // --- [NUEVO] Widget del Slider de Volumen ---
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: currentVolume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (newVolume) {
                          // Actualiza el estado del provider
                          ref.read(volumeProvider.notifier).state = newVolume;
                          // Actualiza el volumen del reproductor en tiempo real
                          audioPlayer.setVolume(newVolume);
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- SECCIÓN DEL CHAT (no cambia) ---
          Expanded(
            child: messagesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  const Center(child: Text('Error al cargar el chat')),
              data: (messages) {
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = userProfile.value?.id == message.authorId;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // --- CAMPO DE TEXTO PARA ENVIAR MENSAJES (no cambia) ---
          if (canChat)
            const MessageInputField()
          else
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey[200],
              child: const Text(
                'Inicia sesión para participar en el chat.',
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
