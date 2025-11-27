// lib/services/bible_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:avivamiento_app/models/bible_book_model.dart';
import 'package:avivamiento_app/models/bible_chapter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ID de la versión de la Biblia (RVR09). Correcto.
const String BIBLE_VERSION_ID = '592420522e16049f-01';
const String API_BASE_URL = 'https://api.scripture.api.bible/v1/bibles';

class BibleService {
  String? _apiKey;
  // Cache map of normalized book names/aliases -> book id (as returned by API)
  final Map<String, String> _bookNameToId = {};
  // Display names of books for suggestions (e.g., 'Génesis', 'Juan')
  final List<String> _bookDisplayNames = [];

  static const String _BOOKS_CACHE_KEY = 'bible_books_cache_v1';

  /// Normalize a book name: lowercase, remove accents and punctuation.
  String _normalize(String s) {
    var out = s.toLowerCase().trim();
    // Simple accent removal for Spanish/English common letters
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ñ': 'n',
      'ü': 'u'
    };
    accents.forEach((k, v) {
      out = out.replaceAll(k, v);
    });
    // Remove punctuation
    out = out.replaceAll(RegExp(r"[^a-z0-9 ]"), ' ');
    out = out.replaceAll(RegExp(r"\s+"), ' ').trim();
    return out;
  }

  /// Ensure we have a lookup map from common name variants to API book ids.
  Future<void> _ensureBookMap() async {
    if (_bookNameToId.isNotEmpty) return;
    // Try load cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_BOOKS_CACHE_KEY);
      if (raw != null && raw.isNotEmpty) {
        final obj = json.decode(raw) as Map<String, dynamic>;
        final Map<String, dynamic> map =
            Map<String, dynamic>.from(obj['map'] ?? {});
        _bookNameToId.clear();
        map.forEach((k, v) {
          _bookNameToId[k] = v.toString();
        });
        _bookDisplayNames.clear();
        final names = (obj['names'] as List<dynamic>?) ?? [];
        for (var n in names) {
          _bookDisplayNames.add(n.toString());
        }
        if (_bookNameToId.isNotEmpty) return;
      }
    } catch (e) {
      print('Warning: failed to load cached book map: $e');
    }

    // If cache not present or empty, fetch from API and build map
    try {
      final books = await fetchBooks();
      _bookNameToId.clear();
      _bookDisplayNames.clear();
      for (var book in books) {
        final id = book.id;
        final name = book.name;
        final norm = _normalize(name);
        _bookDisplayNames.add(name);
        _bookNameToId[norm] = id;

        // Add first word (e.g., '1 John' -> '1 john' and 'john')
        final parts = norm.split(' ');
        if (parts.isNotEmpty) {
          _bookNameToId[parts.last] = id; // last often holds 'john' in '1 john'
          _bookNameToId[parts.first] = id;
        }

        // Add 3-letter code candidate (first 3 letters uppercase), often used in older code
        if (name.length >= 3) {
          final code = name.replaceAll(RegExp(r"[^A-Za-z]"), '');
          if (code.length >= 3) {
            _bookNameToId[code.substring(0, 3).toLowerCase()] = id;
          }
        }
      }

      // Persist cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final toSave =
            json.encode({'map': _bookNameToId, 'names': _bookDisplayNames});
        await prefs.setString(_BOOKS_CACHE_KEY, toSave);
      } catch (e) {
        print('Warning: failed to save book map cache: $e');
      }
    } catch (e) {
      // If fetching books fails (no network), leave map empty and fallbacks will try simple heuristics
      print('Warning: could not build book map: $e');
    }
  }

  /// Public method: smart search or fetch depending on user input.
  /// Tries to detect book/chapter/verse references in many common formats and
  /// falls back to text search when no reference is detected.
  Future<String> searchOrFetch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return 'Consulta vacía.';

    // Fast path: if API-style reference already provided (e.g., GEN.1.1)
    if (RegExp(r'^[A-Za-z]{2,4}\.\d+(?:\.\d+)?\b').hasMatch(q)) {
      try {
        return await _fetchSinglePassage(q, await _getApiKey());
      } catch (_) {}
    }

    // Normalize and try to parse a reference like "Juan 3:16", "Jn 3 16", "1 John 2:3"
    final normalized = _normalize(q);

    // Regex: optional leading number (1,2,3) + book name + chapter + optional verse
    final refRegex =
        RegExp(r'^(?:([123])\s+)?([a-z ]+)\s+(\d+)(?:[:.\s]+(\d+))?\b');
    final m = refRegex.firstMatch(normalized);
    await _ensureBookMap();
    if (m != null) {
      final lead = m.group(1); // '1' in '1 john'
      var bookPart = m.group(2) ?? '';
      final chapter = m.group(3);
      final verse = m.group(4);

      var bookKey = bookPart.trim();
      if (lead != null) bookKey = '${lead.trim()} $bookKey';

      // Try to resolve bookKey to id using map
      String? bookId = _bookNameToId[bookKey];
      bookId ??= _bookNameToId[bookPart.trim()];
      // Try also last word (for '1 john' -> 'john')
      final lastWord = bookKey.split(' ').last;
      bookId ??= _bookNameToId[lastWord];

      // Fallback: use first 3 letters uppercased as code
      if (bookId == null) {
        final code = bookPart.replaceAll(' ', '').toUpperCase();
        if (code.length >= 2 && code.length <= 4) bookId = code;
        if (bookId == null && bookPart.length >= 3) {
          bookId = bookPart.replaceAll(' ', '').substring(0, 3).toUpperCase();
        }
        // Try fuzzy matching against known book names
        bookId ??= _closestBookId(bookKey) ??
            _closestBookId(bookPart) ??
            _closestBookId(lastWord);
      }

      if (bookId != null && chapter != null) {
        final chapterId = '$bookId.$chapter';
        if (verse != null) {
          final passageRef = '$bookId.$chapter.$verse';
          // Try passage first
          final passageResult = await _tryFetchPassageCandidates(
              [passageRef, '$bookId.$chapter.$verse']);
          if (passageResult != null) return passageResult;
        }

        // Try chapter content
        try {
          final content = await fetchChapterContent(chapterId);
          return '$bookId $chapter\n\n$content';
        } catch (e) {
          print('fetchChapterContent failed for $chapterId: $e');
        }
      }
    }

    // If no reference detected, perform a text search
    return _searchBibleText(q, await _getApiKey());
  }

  Future<String?> _tryFetchPassageCandidates(List<String> candidates) async {
    for (var cand in candidates) {
      try {
        final res = await _fetchSinglePassage(cand, await _getApiKey());
        if (res.isNotEmpty && !res.startsWith('Error')) return res;
      } catch (_) {}
    }
    return null;
  }

  // --- Fuzzy matching helpers ---

  /// Levenshtein distance implementation for small string comparisons.
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final la = a.length;
    final lb = b.length;
    List<int> prev = List<int>.generate(lb + 1, (i) => i);
    List<int> curr = List<int>.filled(lb + 1, 0);

    for (var i = 0; i < la; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < lb; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        curr[j + 1] = [
          prev[j + 1] + 1, // deletion
          curr[j] + 1, // insertion
          prev[j] + cost // substitution
        ].reduce((v, e) => v < e ? v : e);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[lb];
  }

  /// Find the closest book id for a given free-text book name using fuzzy matching
  /// Returns null if no sufficiently close match is found.
  String? _closestBookId(String input) {
    if (_bookNameToId.isEmpty) return null;
    final norm = _normalize(input);
    String? bestKey;
    var bestScore = 1e9.toInt();
    for (var key in _bookNameToId.keys) {
      // exact contains or startsWith are good candidates
      if (key == norm) return _bookNameToId[key];
      if (key.contains(norm) || norm.contains(key)) return _bookNameToId[key];

      final d = _levenshtein(norm, key);
      if (d < bestScore) {
        bestScore = d;
        bestKey = key;
      }
    }

    if (bestKey == null) return null;
    // Accept small absolute distances or small relative distances
    final len = norm.length;
    if (bestScore <= 2) return _bookNameToId[bestKey];
    if (len > 4 && bestScore <= (len * 0.35).ceil()) {
      return _bookNameToId[bestKey];
    }
    return null;
  }

  /// Return cached or fetched display names of books for autocomplete.
  Future<List<String>> getAllBookNames() async {
    await _ensureBookMap();
    return List<String>.from(_bookDisplayNames);
  }

  /// Return suggestions for the given prefix (case-insensitive, normalized).
  Future<List<String>> getBookSuggestions(String prefix,
      {int limit = 10}) async {
    if (prefix.trim().isEmpty) return [];
    await _ensureBookMap();
    final p = _normalize(prefix);
    final List<String> matches = [];
    for (var name in _bookDisplayNames) {
      final n = _normalize(name);
      if (n.startsWith(p) || n.contains(p)) {
        matches.add(name);
        if (matches.length >= limit) break;
      }
    }
    return matches;
  }

  /// Parse a human input like "Juan 3:16", "Jn 3 16", "JHN.3.16" or "john 3:16"
  /// and return the API-style passage identifier (e.g. `JHN.3.16` or `JHN.3`) or
  /// `null` if the book couldn't be resolved. This method does not call the API,
  /// it's a pure parsing/resolution helper to validate/normalize user input.
  Future<String?> parseToApiReference(String input) async {
    final q = input.trim();
    if (q.isEmpty) return null;

    // If already API-style, return normalized (uppercase book code)
    final apiStyle = RegExp(r'^([A-Za-z]{2,4})\.(\d+)(?:\.(\d+))?$');
    final mApi = apiStyle.firstMatch(q.replaceAll(' ', ''));
    if (mApi != null) {
      final book = mApi.group(1)!.toUpperCase();
      final chapter = mApi.group(2)!;
      final verse = mApi.group(3);
      return verse != null ? '$book.$chapter.$verse' : '$book.$chapter';
    }

    // Normalize and attempt to extract book, chapter and optional verse
    final normalized = _normalize(q);
    final refRegex =
        RegExp(r'^(?:([123])\s+)?([a-z ]+)\s+(\d+)(?:[:.\s]+(\d+))?\b');
    final m = refRegex.firstMatch(normalized);
    await _ensureBookMap();
    if (m == null) return null;

    final lead = m.group(1);
    var bookPart = m.group(2) ?? '';
    final chapter = m.group(3);
    final verse = m.group(4);

    var bookKey = bookPart.trim();
    if (lead != null) bookKey = '${lead.trim()} $bookKey';

    // Resolve book id using map or fuzzy matching
    String? bookId = _bookNameToId[bookKey];
    bookId ??= _bookNameToId[bookPart.trim()];
    final lastWord = bookKey.split(' ').last;
    bookId ??= _bookNameToId[lastWord];
    bookId ??= _closestBookId(bookKey) ??
        _closestBookId(bookPart) ??
        _closestBookId(lastWord);

    // Avoid sending clearly invalid codes to API
    if (bookId == null) return null;

    if (chapter == null) return null;
    if (verse != null) return '$bookId.$chapter.$verse';
    return '$bookId.$chapter';
  }

  // --- Inicialización de la API Key ---

  /// Obtiene la API key de .env.
  Future<String> _getApiKey() async {
    if (_apiKey != null) return _apiKey!;
    final apiKey = dotenv.env['BIBLE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Error de Configuración: BIBLE_API_KEY no encontrada.');
    }
    _apiKey = apiKey;
    return apiKey;
  }

  /// Headers estándar para todas las peticiones a la API.
  Future<Map<String, String>> _getHeaders() async {
    final apiKey = await _getApiKey();
    return {'api-key': apiKey};
  }

  // --- NUEVOS MÉTODOS PARA NAVEGACIÓN ---

  /// 1. Obtiene la lista de todos los libros de la Biblia.
  Future<List<BibleBookModel>> fetchBooks() async {
    const url = '$API_BASE_URL/$BIBLE_VERSION_ID/books';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> booksList = data['data'];
        return booksList.map((book) => BibleBookModel.fromMap(book)).toList();
      } else {
        throw Exception('Error al cargar libros: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchBooks: $e');
      rethrow;
    }
  }

  /// 2. Obtiene la lista de capítulos para un libro específico (ej: "MAT").
  Future<List<BibleChapterModel>> fetchChapters(String bookId) async {
    final url = '$API_BASE_URL/$BIBLE_VERSION_ID/books/$bookId/chapters';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> chaptersList = data['data'];
        // Filtramos "intro" que a veces viene como capítulo
        return chaptersList
            .where((chap) => chap['number'] != 'intro')
            .map((chap) => BibleChapterModel.fromMap(chap))
            .toList();
      } else {
        throw Exception('Error al cargar capítulos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchChapters: $e');
      rethrow;
    }
  }

  /// 3. Obtiene el contenido completo de un capítulo (ej: "MAT.5").
  Future<String> fetchChapterContent(String chapterId) async {
    // Usamos el endpoint /chapters/ para la lectura.
    // Es más limpio que /passages/ para este caso de uso.
    final url =
        '$API_BASE_URL/$BIBLE_VERSION_ID/chapters/$chapterId?content-type=text&include-verse-numbers=true';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String content = data['data']['content'] as String;
        // Limpiamos etiquetas HTML
        content = content.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();
        return content;
      } else {
        throw Exception('Error al cargar contenido: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchChapterContent: $e');
      rethrow;
    }
  }

  // --- MÉTODOS DE BÚSQUEDA (Los que ya tenías) ---

  /// Busca un pasaje específico (JHN.3.16) o por texto libre.
  Future<String> fetchPassageOrSearch(String query) async {
    final isReference = query.contains('.') ||
        RegExp(r'^[1-3]?\s*[A-Z]{3}').hasMatch(query.toUpperCase().trim());

    if (isReference) {
      return _fetchSinglePassage(query, await _getApiKey());
    } else {
      return _searchBibleText(query, await _getApiKey());
    }
  }

  Future<String> _fetchSinglePassage(
      String bookChapterVerse, String apiKey) async {
    final url =
        '$API_BASE_URL/$BIBLE_VERSION_ID/passages/$bookChapterVerse?content-type=text&include-chapter-numbers=false&include-verse-numbers=true';
    try {
      final response =
          await http.get(Uri.parse(url), headers: {'api-key': apiKey});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String content = data['data']['content'] as String;
        content = content.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
        final reference = data['data']['reference'] as String;
        return '$reference\n\n$content';
      } else {
        return 'Error ${response.statusCode}: Pasaje no encontrado. Verifica el formato (ej: JHN.3.16).';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }

  Future<String> _searchBibleText(String query, String apiKey) async {
    final url =
        '$API_BASE_URL/$BIBLE_VERSION_ID/search?query=$query&limit=20&sort=relevance';
    try {
      final response =
          await http.get(Uri.parse(url), headers: {'api-key': apiKey});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final searchData = data['data'] as Map<String, dynamic>;
        final total = searchData['total'] as int;
        final verses = searchData['verses'] as List<dynamic>;

        if (total == 0) {
          return 'No se encontraron resultados para: "$query".';
        }

        final results = StringBuffer();
        results.write('Resultados para "$query" ($total encontrados):\n\n');
        for (var verse in verses) {
          final text = verse['text'] as String;
          final reference = verse['reference'] as String;
          results.write('$reference: $text\n\n');
        }
        return results.toString();
      } else {
        return 'Error ${response.statusCode} al buscar.';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}
