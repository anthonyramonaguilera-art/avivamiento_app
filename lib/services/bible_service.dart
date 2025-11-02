import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ID de la versión de la Biblia. 
// Usamos la Reina Valera 1909 (RVR09) según tu lista de autorizadas.
const String BIBLE_VERSION_ID = '592420522e16049f-01'; // Reina Valera 1909 (RVR09)

/// Realiza una petición a la API.Bible para obtener el contenido de un pasaje o realizar una búsqueda.
/// 
/// Si el `query` tiene el formato de referencia (ej: JHN.3.16), busca el pasaje.
/// Si es texto libre, realiza una búsqueda de concordancia.
Future<String> fetchPassageContent(String query) async {
  // 1. Obtiene la clave de API del archivo .env
  // Asumimos que dotenv.load() ya se llamó en main.dart
  final apiKey = dotenv.env['BIBLE_API_KEY']; 
  
  if (apiKey == null || apiKey.isEmpty) {
    return 'Error de Configuración: BIBLE_API_KEY no encontrada o vacía en el archivo .env. Asegúrate de tener tu clave en el archivo .env.';
  }

  // Comprobación heurística para determinar si es una referencia (contiene '.' o es un libro corto)
  final isReference = query.contains('.') || RegExp(r'^[1-3]?\s*[A-Z]{3}').hasMatch(query.toUpperCase().trim());

  if (isReference) {
    return _fetchSinglePassage(query, apiKey);
  } else {
    return _searchBibleText(query, apiKey);
  }
}

/// Función interna para buscar un único pasaje (referencia exacta).
Future<String> _fetchSinglePassage(String bookChapterVerse, String apiKey) async {
  // Construye la URL para buscar el pasaje.
  final url = 'https://api.scripture.api.bible/v1/bibles/$BIBLE_VERSION_ID/passages/$bookChapterVerse?content-type=text&include-chapter-numbers=false&include-verse-numbers=true';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: { 'api-key': apiKey },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // La versión en español suele contener etiquetas HTML, las eliminamos para limpiar el texto.
      String content = data['data']['content'] as String;
      content = content.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
      
      final reference = data['data']['reference'] as String;
      
      return '$reference\n\n$content';

    } else if (response.statusCode == 404) {
       return 'Error 404: Pasaje no encontrado. Verifica el formato de la referencia (ej: JHN.3.16).';
    } else if (response.statusCode == 403) {
       // Si falla, llamamos a la función para obtener la lista de Biblias en español.
       final availableBibles = await fetchAuthorizedBibles(apiKey);
       return 'Error 403 (Prohibido): La Biblia con ID "$BIBLE_VERSION_ID" no está autorizada para tu clave.\n\n$availableBibles';
    } 
    else {
      // Captura otros errores como 401 (API Key incorrecta)
      return 'Error ${response.statusCode}. Revisa tu API Key.';
    }
  } catch (e) {
    return 'Error de conexión: $e';
  }
}


/// Función interna para realizar una búsqueda de texto (concordancia).
Future<String> _searchBibleText(String query, String apiKey) async {
  // Construye la URL para la búsqueda de texto. Limitamos a 20 resultados por relevancia.
  final url = 'https://api.scripture.api.bible/v1/bibles/$BIBLE_VERSION_ID/search?query=$query&limit=20&sort=relevance';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: { 'api-key': apiKey },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final searchData = data['data'] as Map<String, dynamic>;
      final total = searchData['total'] as int;
      final verses = searchData['verses'] as List<dynamic>;

      if (total == 0) {
        return 'No se encontraron resultados para la búsqueda: "$query".';
      }

      // Formatea los resultados de la búsqueda
      final results = StringBuffer();
      results.write('Resultados de búsqueda para "$query" ($total encontrados):\n\n');
      
      for (var verse in verses) {
        // El texto del versículo viene sin etiquetas HTML/versículos.
        final text = verse['text'] as String;
        final reference = verse['reference'] as String;
        results.write('$reference: $text\n\n');
      }

      return results.toString();

    } else if (response.statusCode == 403) {
       final availableBibles = await fetchAuthorizedBibles(apiKey);
       return 'Error 403 (Prohibido): La Biblia con ID "$BIBLE_VERSION_ID" no está autorizada para tu clave.\n\n$availableBibles';
    } 
    else {
      return 'Error ${response.statusCode} al buscar. Revisa tu API Key.';
    }
  } catch (e) {
    return 'Error de conexión durante la búsqueda: $e';
  }
}

/// Obtiene la lista de Biblias autorizadas FILTRANDO por español.
Future<String> fetchAuthorizedBibles(String apiKey) async {
  // Usamos el código ISO 639-3 'spa' (Spanish) para filtrar.
  const url = 'https://api.scripture.api.bible/v1/bibles?language=spa';
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: { 'api-key': apiKey },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final bibles = data['data'] as List<dynamic>;
      
      if (bibles.isEmpty) {
        return 'Tu clave de API está activa, pero NO tiene acceso a NINGUNA Biblia en ESPAÑOL. Debes autorizar al menos una en tu panel.';
      }
      
      // Construye un mensaje con los IDs disponibles
      final ids = bibles.map((b) => '${b['name']} (${b['id']})').join('\n  - ');
      return 'Tu clave SÍ tiene acceso a las siguientes Biblias en ESPAÑOL:\n  - $ids\n\n**SOLUCIÓN:** Copia el ID de la Biblia que deseas y pégalo en la constante BIBLE_VERSION_ID.';
    
    } else if (response.statusCode == 401) {
      return 'Tu BIBLE_API_KEY no es válida o está incompleta. El error 401 indica que la clave es rechazada.';
    } else {
      return 'Error al obtener lista de Biblias: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error de conexión al obtener la lista: $e';
  }
}
