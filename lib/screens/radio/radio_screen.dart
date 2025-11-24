// lib/screens/radio/radio_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart'; // <-- ¡NUEVA IMPORTACIÓN!
// Removed Lottie dependency — using a custom lightweight visualizer instead
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
          // Área superior con el logo y controles (Visualmente separada)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'radio_logo',
                  child: Image.asset(
                    'assets/images/radio_logo.png',
                    height: 160,
                    width: 160,
                  ),
                ),
                const SizedBox(height: 24),

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
                        child: SizedBox(
                          height: 60, 
                          width: 60, 
                          child: CircularProgressIndicator()
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Visualizer
                        PlayVisualizer(isPlaying: isPlaying),
                        const SizedBox(height: 16),
                        Text(
                          'Radio Avivamiento En Vivo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        
                        // Botón de Play/Pause Moderno
                        Material(
                          color: Theme.of(context).colorScheme.primary,
                          elevation: 8,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () {
                              if (isPlaying) {
                                audioHandler.pause();
                              } else {
                                audioHandler.play();
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Chat Area
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: messagesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    Center(child: Text('Error al cargar el chat', style: TextStyle(color: Theme.of(context).colorScheme.error))),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Sé el primero en escribir...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
          ),
          if (canChat)
            const MessageInputField()
          else
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Inicia sesión para participar en el chat.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
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

// A small, modern and minimal audio visualizer used instead of Lottie.
class PlayVisualizer extends StatefulWidget {
  final bool isPlaying;
  const PlayVisualizer({super.key, required this.isPlaying});

  @override
  State<PlayVisualizer> createState() => _PlayVisualizerState();
}

class _PlayVisualizerState extends State<PlayVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _barOne;
  late final Animation<double> _barTwo;
  late final Animation<double> _barThree;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _barOne = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut)),
    );
    _barTwo = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.15, 1.0, curve: Curves.easeInOut)),
    );
    _barThree = Tween<double>(begin: 0.35, end: 0.95).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeInOut)),
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PlayVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 40.0;
    const barWidth = 8.0;
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 60,
      width: 150,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(maxBarHeight * _barOne.value, barWidth, color),
              _buildBar(maxBarHeight * _barTwo.value, barWidth,
                  color.withOpacity(0.9)),
              _buildBar(maxBarHeight * _barThree.value, barWidth,
                  color.withOpacity(0.75)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBar(double height, double width, Color color) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}
