// lib/providers/audio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

/// Este Provider es una plantilla.
/// Será "sobrescrito" (overridden) en 'main.dart' con la instancia
/// real del AudioHandler una vez que se inicialice.
///
/// Los widgets usarán este provider para acceder al handler.
final audioHandlerProvider = Provider<AudioHandler>((ref) {
  throw UnimplementedError('AudioHandler no inicializado');
});
