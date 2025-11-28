// lib/screens/livestreams/youtube_player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Pantalla para reproducir videos de YouTube con entrada inmediata a fullscreen.
///
/// Esta pantalla utiliza [YoutubePlayerIFrame] para reproducir videos embebidos
/// y proporciona una experiencia inmersiva premium con:
/// - Entrada automática a pantalla completa al iniciar
/// - Orientación adaptativa (landscape para videos, portrait para shorts)
/// - Transiciones suaves sin flickering
/// - Controles overlay que se auto-ocultan
/// - Gestión inteligente de orientación del dispositivo
class YouTubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final bool isShort;

  const YouTubePlayerScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    this.isShort = false,
  });

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Auto-ocultar controles después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlayerReady) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: false,
        enableCaption: true,
        playsInline: true, // Explícito para asegurar reproducción inline
      ),
    );

    // Listener para actualizar el estado de ready
    _controller.listen((event) {
      if (event.playerState == PlayerState.playing && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    });
  }

  /// Toggle de visibilidad de controles
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Si mostramos los controles, ocultarlos automáticamente después de 3 segundos
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                widget.videoTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: widget.isShort ? 9 / 16 : 16 / 9,
              child: Stack(
                children: [
                  // El reproductor de video
                  YoutubePlayer(
                    controller: _controller,
                    aspectRatio: widget.isShort ? 9 / 16 : 16 / 9,
                  ),

                  // Loading indicator
                  if (!_isPlayerReady)
                    Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando video...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Overlay de información (aparece con los controles)
                  if (_showControls && _isPlayerReady)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.videoTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Avivamiento CIV',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (widget.isShort) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'SHORT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
