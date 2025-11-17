// lib/services/audio_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Define el stream de radio como un MediaItem estático.
/// Esto es lo que verá la notificación y la pantalla de bloqueo.
final _radioMediaItem = MediaItem(
  id: 'radio_stream',
  album: 'Radio en Vivo',
  title: 'Avivamiento 101.9 FM',
  artist: 'Centro Internacional Avivamiento',
  // Reemplaza la URL por la de tu logo/imagen pública.
  artUri: Uri.parse('https://i.ibb.co/WWwj5fT4/radio-logo.png'),
);

/// El AudioHandler que gestiona la reproducción de la radio.
class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  RadioAudioHandler() {
    // Escuchamos los cambios de estado de 'just_audio' y los
    // retransmitimos a 'audio_service' (para la notificación).
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Cargamos el stream de la radio al iniciar
    _loadRadioStream();
  }

  Future<void> _loadRadioStream() async {
    const streamUrl = 'https://stream.zeno.fm/9vrkfkz49ehvv';
    try {
      // Configuramos el 'MediaItem' para que 'audio_service' sepa qué mostrar
      mediaItem.add(_radioMediaItem);

      // Le decimos a just_audio que cargue el stream
      await _player.setUrl(streamUrl);
    } catch (e) {
      print("Error al cargar el stream de radio: $e");
    }
  }

  @override
  Future<void> play() {
    // AÑADIDO: diagnóstico para saber cuándo se llama a play()
    print('!!!!!!!!!!!!!! [RadioAudioHandler] play() CALLED !!!!!!!!!!!!!!');
    return _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Transforma los eventos de 'just_audio' en estados de 'audio_service'.
  PlaybackState _transformEvent(PlaybackEvent event) {
    AudioProcessingState mapState(ProcessingState state) {
      switch (state) {
        case ProcessingState.idle:
          return AudioProcessingState.idle;
        case ProcessingState.loading:
          return AudioProcessingState.loading;
        case ProcessingState.buffering:
          return AudioProcessingState.buffering;
        case ProcessingState.ready:
          return AudioProcessingState.ready;
        case ProcessingState.completed:
          return AudioProcessingState.completed;
      }
    }

    return PlaybackState(
      controls: const [
        MediaControl.play,
        MediaControl.pause,
        MediaControl.stop
      ],
      systemActions: const {MediaAction.seek},
      processingState: mapState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
