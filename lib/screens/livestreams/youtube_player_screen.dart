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
  bool _isPlayerReady = false; // Para mostrar/ocultar el spinner
  bool _showControls = true; // Para mostrar/ocultar el overlay
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    // Ocultar barras del sistema para experiencia inmersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initializePlayer();
  }

  void _initializePlayer() {
    // 1. CONFIGURACIÓN DEL CONTROLADOR
    // inicializamos con params básicos. IMPORTANTE: strictRelatedVideos ayuda en Android.
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true,
        enableCaption: true,
        enableJavaScript: true, // CRÍTICO para que funcione el iframe
        playsInline: true,
      ),
    );

    // 2. CARGA DIFERIDA (LAZY LOAD)
    // Esperamos 500ms para asegurar que la vista está montada antes de cargar el ID.
    // Esto evita el error de "setSize undefined" en dispositivos lentos.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.loadVideoById(videoId: widget.videoId);
      }
    });

    // 3. ESCUCHA DE ESTADOS (STATE LISTENER)
    // En lugar de onReady (que no existe en tu versión), escuchamos cambios.
    _controller.listen((event) {
      if (!mounted) return;

      // Si el video está "cued" (listo), "buffering" (cargando datos) o "playing"
      // consideramos que el reproductor ya cargó visualmente.
      if (!_isPlayerReady &&
          (event.playerState == PlayerState.cued ||
              event.playerState == PlayerState.buffering ||
              event.playerState == PlayerState.playing)) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    });

    // 4. FAILSAFE (SEGURIDAD)
    // Si por alguna razón el listener falla (internet lento), a los 4s forzamos mostrar el video.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_isPlayerReady) {
        setState(() => _isPlayerReady = true);
      }
    });

    _resetControlsTimer();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) setState(() => _showControls = false);
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    // Devolvemos la UI del sistema a la normalidad
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    try {
      _controller.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para saber el tamaño real de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // CAPA 1: EL REPRODUCTOR
          Center(
            child: SizedBox(
              width: size.width,
              // Ajustamos la altura según si es Short o Video normal
              height: widget.isShort ? size.height : size.width * (9 / 16),
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: widget.isShort ? 9 / 16 : 16 / 9,
                enableFullScreenOnVerticalDrag: false,
              ),
            ),
          ),

          // CAPA 2: OVERLAY DE CONTROLES (Solo Widgets nativos)
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior
                .translucent, // Permite tocar a través de áreas vacías
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Stack(
                children: [
                  // SOMBRA SUPERIOR (GRADIENTE)
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

                  // BOTÓN ATRÁS
                  Positioned(
                    top: 40, // Margen seguro superior
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // SOMBRA INFERIOR (GRADIENTE)
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

                  // INFORMACIÓN DEL VIDEO
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
                        // Badge / Etiqueta simple
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

          // CAPA 3: INDICADOR DE CARGA (Con fondo negro para tapar la carga fea)
          if (!_isPlayerReady)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Cargando...",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
