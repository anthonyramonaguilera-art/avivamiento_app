// lib/screens/livestreams/livestreams_screen.dart

import 'package:flutter/foundation.dart'; // [NUEVO] Importante para detectar la plataforma web
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/livestream_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/livestreams/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // [NUEVO] Lo necesitamos de vuelta para la web

// El StreamProvider no cambia
final livestreamsProvider = StreamProvider<List<LivestreamModel>>((ref) {
  final livestreamService = ref.watch(livestreamServiceProvider);
  return livestreamService.getLivestreamsStream();
});

class LivestreamsScreen extends ConsumerWidget {
  const LivestreamsScreen({super.key});

  // [NUEVO] Reincorporamos la función para abrir URLs para usarla en la web
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('No se pudo lanzar $urlString');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestreamsAsyncValue = ref.watch(livestreamsProvider);

    return Scaffold(
      body: livestreamsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar las transmisiones: $error')),
        data: (livestreams) {
          if (livestreams.isEmpty) {
            return const Center(
              child: Text('No hay transmisiones disponibles.'),
            );
          }

          return ListView.builder(
            itemCount: livestreams.length,
            itemBuilder: (context, index) {
              final livestream = livestreams[index];
              final isLiveNow = livestream.isLive;

              return Card(
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // [CAMBIO CLAVE] Lógica condicional para web vs. móvil
                  onTap: () {
                    if (kIsWeb) {
                      // Si estamos en la web, abre en una nueva pestaña.
                      _launchURL(livestream.videoUrl);
                    } else {
                      // Si estamos en móvil, abre el reproductor integrado.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: livestream.videoUrl,
                            title: livestream.title,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // El resto del widget de la tarjeta no cambia...
                      Stack(
                        children: [
                          Image.network(
                            livestream.thumbnailUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 200,
                                child: Icon(
                                  Icons.videocam_off,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                          if (isLiveNow)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'EN VIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          livestream.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
