// lib/services/youtube_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:avivamiento_app/models/youtube_video_model.dart';

/// Servicio para interactuar con la YouTube Data API v3.
///
/// Este servicio permite obtener videos de un canal de YouTube,
/// separándolos entre videos largos (Predicas) y cortos (Shorts).
class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // Handle del canal de Avivamiento CIV
  static const String _channelHandle = 'Avivamientociv';

  // ID del canal (se resolverá dinámicamente o usará este como fallback)
  // Este ID se puede actualizar una vez que se obtenga de la API
  String? _channelId;

  late final String _apiKey;

  YouTubeService() {
    _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
    if (_apiKey.isEmpty || _apiKey == 'YOUR_YOUTUBE_API_KEY_HERE') {
      print('⚠️  WARNING: YouTube API Key no configurada en .env');
    }
  }

  /// Obtiene el ID del canal a partir del handle o nombre de usuario
  ///
  /// Esto es necesario porque YouTube usa IDs internos, no los handles visibles
  Future<String?> getChannelIdFromHandle(String handle) async {
    try {
      // Remover @ si está presente
      final cleanHandle = handle.replaceAll('@', '');

      final url = Uri.parse(
          '$_baseUrl/search?part=snippet&type=channel&q=$cleanHandle&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          return items[0]['id']['channelId'];
        }
      } else {
        print('Error al buscar canal: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error en getChannelIdFromHandle: $e');
    }
    return null;
  }

  /// Obtiene todos los videos del canal (tanto largos como cortos)
  ///
  /// Parámetros:
  /// - [maxResults]: Número máximo de resultados a obtener (default: 50)
  /// - [order]: Orden de los resultados ('date', 'viewCount', 'rating')
  /// - [videoDuration]: Filtro de duración ('any', 'long', 'medium', 'short')
  Future<List<YouTubeVideoModel>> getAllChannelVideos({
    int maxResults = 50,
    String order = 'date',
    String videoDuration = 'any',
  }) async {
    try {
      // Paso 0: Resolver el ID del canal si aún no lo tenemos
      if (_channelId == null) {
        _channelId = await getChannelIdFromHandle(_channelHandle);
        if (_channelId == null) {
          print('Error: No se pudo obtener el ID del canal');
          return [];
        }
      }

      // Paso 1: Obtener la lista de videos del canal usando search
      final searchUrl = Uri.parse('$_baseUrl/search?'
          'part=snippet&'
          'channelId=$_channelId&'
          'maxResults=$maxResults&'
          'order=$order&'
          'type=video&'
          'videoDuration=$videoDuration&' // Añadido filtro de duración
          'key=$_apiKey');

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        print('Error al buscar videos: ${searchResponse.statusCode}');
        print('Respuesta: ${searchResponse.body}');
        return [];
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List? ?? [];

      if (items.isEmpty) {
        return [];
      }

      // Extraer los IDs de los videos
      final videoIds = items
          .map((item) => item['id']['videoId'] as String?)
          .where((id) => id != null)
          .join(',');

      // Paso 2: Obtener detalles de los videos (incluyendo duración) usando videos endpoint
      final videosUrl = Uri.parse('$_baseUrl/videos?'
          'part=snippet,contentDetails&'
          'id=$videoIds&'
          'key=$_apiKey');

      final videosResponse = await http.get(videosUrl);

      if (videosResponse.statusCode != 200) {
        print(
            'Error al obtener detalles de videos: ${videosResponse.statusCode}');
        return [];
      }

      final videosData = json.decode(videosResponse.body);
      final videoItems = videosData['items'] as List? ?? [];

      // Convertir a modelos
      final models = videoItems.map((item) {
        final model = YouTubeVideoModel.fromJson(item);
        print(
            'Video: ${model.title} | Duration: ${model.duration} | IsShort: ${model.isShort}');
        return model;
      }).toList();

      return models;
    } catch (e) {
      print('Error en getAllChannelVideos: $e');
      return [];
    }
  }

  /// Obtiene solo los videos largos del canal (excluye Shorts)
  ///
  /// Filtra los videos que tienen una duración mayor a 3 minutos
  Future<List<YouTubeVideoModel>> getChannelVideos({
    int maxResults = 50,
    String order = 'date',
  }) async {
    // Para videos largos, podríamos usar videoDuration='medium' o 'long',
    // pero 'any' es más seguro para no perder videos de 4-20 min.
    // Filtramos localmente.
    final allVideos = await getAllChannelVideos(
      maxResults: maxResults,
      order: order,
      videoDuration: 'any',
    );

    // Filtrar solo videos largos (no Shorts)
    return allVideos.where((video) => !video.isShort).toList();
  }

  /// Obtiene solo los Shorts del canal
  ///
  /// Usa el filtro de API videoDuration='short' (< 4 min)
  Future<List<YouTubeVideoModel>> getChannelShorts({
    int maxResults = 50,
    String order = 'date',
  }) async {
    // Solicitamos específicamente videos cortos a la API
    final shortVideos = await getAllChannelVideos(
      maxResults: maxResults,
      order: order,
      videoDuration: 'short', // Esto retorna videos < 4 minutos
    );

    // Filtrar localmente para asegurar que cumplen nuestro criterio de Short (<= 3 min)
    return shortVideos.where((video) => video.isShort).toList();
  }

  /// Busca videos en el canal por término de búsqueda
  Future<List<YouTubeVideoModel>> searchChannelVideos(
    String query, {
    int maxResults = 20,
  }) async {
    try {
      // Resolver el ID del canal si aún no lo tenemos
      if (_channelId == null) {
        _channelId = await getChannelIdFromHandle(_channelHandle);
        if (_channelId == null) {
          print('Error: No se pudo obtener el ID del canal');
          return [];
        }
      }

      final searchUrl = Uri.parse('$_baseUrl/search?'
          'part=snippet&'
          'channelId=$_channelId&'
          'maxResults=$maxResults&'
          'q=$query&'
          'type=video&'
          'key=$_apiKey');
      final response = await http.get(searchUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];

        // Obtener IDs y detalles completos
        if (items.isEmpty) return [];

        final videoIds = items
            .map((item) => item['id']['videoId'] as String?)
            .where((id) => id != null)
            .join(',');

        final videosUrl = Uri.parse('$_baseUrl/videos?'
            'part=snippet,contentDetails&'
            'id=$videoIds&'
            'key=$_apiKey');

        final videosResponse = await http.get(videosUrl);

        if (videosResponse.statusCode == 200) {
          final videosData = json.decode(videosResponse.body);
          final videoItems = videosData['items'] as List? ?? [];

          return videoItems
              .map((item) => YouTubeVideoModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('Error en searchChannelVideos: $e');
    }
    return [];
  }
}
