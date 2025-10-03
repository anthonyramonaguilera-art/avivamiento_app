// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart'; // Para saber quién envía el mensaje
import 'package:avivamiento_app/providers/audio_provider.dart'; // Providers de audio
import 'package:avivamiento_app/providers/chat_provider.dart'; // Para chatMessagesProvider

// Widgets del chat que crearemos a continuación
import 'package:avivamiento_app/screens/radio/widgets/chat_bubble.dart';
import 'package:avivamiento_app/screens/radio/widgets/message_input_field.dart';

// ... (los providers de audio no cambian)

class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});
  final String streamUrl = 'https://stream.zeno.fm/9vrkfkz49ehvv';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final isPlaying = playerStateAsync.maybeWhen(
      data: (state) => state == PlayerState.playing,
      orElse: () => false,
    );

    // [NUEVO] Leemos los mensajes del chat
    final messagesAsyncValue = ref.watch(chatMessagesProvider);
    final userProfile = ref.watch(userProfileProvider);
    final bool canChat =
        userProfile.value != null && userProfile.value?.rol != 'Invitado';

    return Scaffold(
      body: Column(
        children: [
          // --- SECCIÓN DEL REPRODUCTOR (no cambia) ---
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                      await audioPlayer.play(UrlSource(streamUrl));
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- SECCIÓN DEL CHAT (NUEVO) ---
          Expanded(
            child: messagesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  const Center(child: Text('Error al cargar el chat')),
              data: (messages) {
                return ListView.builder(
                  reverse: true, // Para que los mensajes nuevos aparezcan abajo
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Comparamos el ID del autor del mensaje con el ID del usuario actual
                    final isMe = userProfile.value?.id == message.authorId;
                    return ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),

          // --- CAMPO DE TEXTO PARA ENVIAR MENSAJES (NUEVO) ---
          if (canChat)
            MessageInputField()
          else
            // Mensaje para usuarios no registrados o invitados
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
