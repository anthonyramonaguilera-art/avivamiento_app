import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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

  // ESTADOS
  bool _isPlayerReady = false; // Controla el spinner de carga
  bool _showControls = true; // Controla la visibilidad de la UI
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    // Ocultar barras del sistema para experiencia inmersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true,
        enableCaption: true,
        enableJavaScript: true,
        playsInline: true,
        // LA SOLUCIÓN CLAVE: Política de origen para evitar bloqueos
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    // Carga inicial del video
    _controller.loadVideoById(videoId: widget.videoId);

    // Escuchar cambios de estado para quitar el spinner
    _controller.listen((event) {
      if (!mounted) return;

      if (!_isPlayerReady &&
          (event.playerState == PlayerState.cued ||
              event.playerState == PlayerState.buffering ||
              event.playerState == PlayerState.playing)) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    });

    // Iniciar temporizador para ocultar controles automáticamente
    _startControlsTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    // Restaurar UI del sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Cierre limpio del controlador
    try {
      _controller.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // CAPA 1: VIDEO
          Center(
            child: SizedBox(
              width: size.width,
              height: widget.isShort ? size.height : size.width * (9 / 16),
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: widget.isShort ? 9 / 16 : 16 / 9,
                enableFullScreenOnVerticalDrag: false,
              ),
            ),
          ),

          // CAPA 2: CONTROLES (OVERLAY)
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.translucent,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  // Gradiente Superior
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Botón Atrás
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Gradiente Inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Info del Video
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.videoTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  blurRadius: 2,
                                  color: Colors.black,
                                  offset: Offset(0, 1))
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "LIVE / VIDEO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CAPA 3: LOADING
          if (!_isPlayerReady)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
