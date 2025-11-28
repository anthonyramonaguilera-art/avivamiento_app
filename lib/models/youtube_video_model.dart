// lib/models/youtube_video_model.dart

/// Representa un video de YouTube obtenido a través de la YouTube Data API v3.
///
/// Contiene información básica del video como ID, título, miniatura, fecha de publicación
/// y duración. El campo [isShort] permite diferenciar entre videos largos y Shorts.
class YouTubeVideoModel {
  /// El ID único del video en YouTube
  final String id;

  /// El título del video
  final String title;

  /// URL de la miniatura del video (preferiblemente en resolución media o alta)
  final String thumbnailUrl;

  /// Fecha de publicación del video
  final DateTime publishedAt;

  /// Duración del video en formato ISO 8601 (ej: "PT15M33S" para 15 minutos 33 segundos)
  final String duration;

  /// Indica si el video es un Short (videos cortos, típicamente < 60 segundos)
  final bool isShort;

  /// Descripción del video (opcional)
  final String description;

  YouTubeVideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.duration,
    required this.isShort,
    this.description = '',
  });

  /// Factory constructor para crear una instancia desde el JSON de la API de YouTube
  factory YouTubeVideoModel.fromJson(Map<String, dynamic> json) {
    // Extraer el ID del video según el tipo de respuesta (search o videos)
    String videoId;
    if (json['id'] is String) {
      videoId = json['id'];
    } else if (json['id'] is Map) {
      videoId = json['id']['videoId'] ?? '';
    } else {
      videoId = '';
    }

    // Obtener información del snippet
    final snippet = json['snippet'] ?? {};

    // Obtener la mejor miniatura disponible
    final thumbnails = snippet['thumbnails'] ?? {};
    String thumbnailUrl = '';
    if (thumbnails['high'] != null) {
      thumbnailUrl = thumbnails['high']['url'] ?? '';
    } else if (thumbnails['medium'] != null) {
      thumbnailUrl = thumbnails['medium']['url'] ?? '';
    } else if (thumbnails['default'] != null) {
      thumbnailUrl = thumbnails['default']['url'] ?? '';
    }

    // Parsear la fecha de publicación
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(snippet['publishedAt'] ?? '');
    } catch (e) {
      publishedAt = DateTime.now();
    }

    // Obtener duración del contentDetails (si está disponible)
    final contentDetails = json['contentDetails'] ?? {};
    final duration = contentDetails['duration'] ?? 'PT0S';

    // Determinar si es un Short basándose en la duración
    // YouTube Shorts ahora pueden durar hasta 3 minutos (180 segundos)
    final isShort = _isShortVideo(duration);

    return YouTubeVideoModel(
      id: videoId,
      title: snippet['title'] ?? 'Sin título',
      thumbnailUrl: thumbnailUrl,
      publishedAt: publishedAt,
      duration: duration,
      isShort: isShort,
      description: snippet['description'] ?? '',
    );
  }

  /// Determina si es un Short basándose en la duración
  ///
  /// YouTube Shorts ahora pueden durar hasta 3 minutos (180 segundos).
  /// Usamos un umbral de 190 segundos para dar margen.
  static bool _isShortVideo(String duration) {
    // Parsear duración ISO 8601 (ej: PT1M30S = 1 minuto 30 segundos)
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    if (match == null) return false;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    // Consideramos Short si es menor a 190 segundos (3 minutos con margen)
    // y no tiene horas
    return hours == 0 && totalSeconds > 0 && totalSeconds <= 190;
  }

  /// Obtiene la duración en formato legible (ej: "15:33" o "1:30:45")
  String getFormattedDuration() {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    if (match == null) return '0:00';

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
