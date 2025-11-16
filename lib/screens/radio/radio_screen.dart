// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart'; // <-- ¡NUEVA IMPORTACIÓN!
import 'package:lottie/lottie.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/audio_provider.dart'; // <-- ¡Este es nuestro nuevo provider!
import 'package:avivamiento_app/providers/chat_provider.dart';
import 'package:avivamiento_app/screens/radio/widgets/chat_bubble.dart';
import 'package:avivamiento_app/screens/radio/widgets/message_input_field.dart';
import 'package:avivamiento_app/screens/auth_screen.dart';

// Ya no necesitamos el 'volumeProvider', just_audio maneja esto mejor,
// aunque para una radio en vivo, el control de volumen en la app es redundante
// (el usuario usa los botones físicos del teléfono).

class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});
  // Ya no necesitamos el streamUrl aquí, el Handler lo gestiona.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Obtenemos la instancia del AudioHandler desde Riverpod
    final audioHandler = ref.watch(audioHandlerProvider);
    final messagesAsyncValue = ref.watch(chatMessagesProvider);
    final userProfile = ref.watch(userProfileProvider);
    final bool canChat =
        userProfile.value != null && userProfile.value?.rol != 'Invitado';

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/radio_logo.png',
                  height: 150,
                  width: 150,
                ),

                // 2. Escuchamos el PlaybackState del handler
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final playbackState = snapshot.data;
                    final isPlaying = playbackState?.playing ?? false;
                    final processingState = playbackState?.processingState;

                    // Mostramos un indicador de carga si está conectando
                    if (processingState == AudioProcessingState.loading ||
                        processingState == AudioProcessingState.buffering) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    // El Lottie ahora se anima basado en el stream
                    return Column(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 150,
                          child: Lottie.asset(
                            'assets/animations/sound_wave.json',
                            animate: isPlaying,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Radio Avivamiento En Vivo',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 70,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // 3. Enviamos comandos al Handler
                            if (isPlaying) {
                              audioHandler.pause();
                            } else {
                              audioHandler.play();
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                // Eliminamos el slider de volumen. Es innecesario para
                // una radio y complica la UI. El usuario usará los
                // controles de volumen nativos del teléfono.
              ],
            ),
          ),
          const Divider(height: 1),
          // El resto de tu UI (Chat, etc.) no cambia.
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
          if (canChat)
            const MessageInputField()
          else
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Inicia sesión para participar en el chat.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    child: const Text('Iniciar Sesión o Registrarse'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
