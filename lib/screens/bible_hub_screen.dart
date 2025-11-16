// lib/screens/bible_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/bible_book_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/bible_chapter_screen.dart';
import 'package:avivamiento_app/screens/bible_reader_screen.dart';

// --- State Management (Providers) ---

/// Provider que almacena la consulta de búsqueda actual.
/// La UI reaccionará a los cambios en este estado.
final bibleSearchQueryProvider = StateProvider<String>((_) => '');

/// Provider que carga la lista de libros (AT/NT) una sola vez.
final bibleBooksProvider =
    FutureProvider<Map<String, List<BibleBookModel>>>((ref) async {
  // Usamos el provider de servicio que definiremos en services_provider.dart
  final bibleService = ref.watch(bibleServiceProvider);
  final books = await bibleService.fetchBooks();
  final Map<String, List<BibleBookModel>> grouped = {
    'Antiguo Testamento': [],
    'Nuevo Testamento': [],
  };
  for (var book in books) {
    if (book.testament == 'OT') {
      grouped['Antiguo Testamento']!.add(book);
    } else if (book.testament == 'NT') {
      grouped['Nuevo Testamento']!.add(book);
    }
  }
  return grouped;
});

/// Provider que ejecuta la búsqueda.
/// Es un `.family` para tomar la consulta como parámetro.
/// Es `.autoDispose` para cancelar la búsqueda si el usuario sale.
final bibleSearchProvider =
    FutureProvider.autoDispose.family<String, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return 'Inicia una búsqueda.';
  }
  final bibleService = ref.watch(bibleServiceProvider);
  return bibleService.searchOrFetch(query);
});

// --- UI (Pantalla Principal) ---

class BibleHubScreen extends ConsumerStatefulWidget {
  const BibleHubScreen({super.key});

  @override
  ConsumerState<BibleHubScreen> createState() => _BibleHubScreenState();
}

class _BibleHubScreenState extends ConsumerState<BibleHubScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Limpiamos la búsqueda al entrar, si es que había algo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(bibleSearchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    ref.read(bibleSearchQueryProvider.notifier).state = query;
    _searchFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado de la consulta
    final searchQuery = ref.watch(bibleSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Santa Biblia (RVR09)'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .copyWith(bottom: 8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Buscar (ej. Juan 3:16 o "amor")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmitted('');
                        },
                      )
                    : null,
                // Ajustes de padding para un look más moderno
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: searchQuery.isEmpty
            // Estado 1: Navegación (búsqueda vacía)
            ? const _BibleBooksList(key: ValueKey('books_list'))
            // Estado 2: Resultados (búsqueda activa)
            : _BibleSearchResults(
                key: ValueKey(searchQuery), // La clave cambia con la consulta
                query: searchQuery,
              ),
      ),
    );
  }
}

// --- Helper Widget: Lista de Libros (Estado por Defecto) ---
class _BibleBooksList extends ConsumerWidget {
  const _BibleBooksList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(bibleBooksProvider);

    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error al cargar libros: $err')),
      data: (groupedBooks) {
        final otBooks = groupedBooks['Antiguo Testamento']!;
        final ntBooks = groupedBooks['Nuevo Testamento']!;

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            _buildBookSection(context, 'Antiguo Testamento', otBooks),
            _buildBookSection(context, 'Nuevo Testamento', ntBooks),
          ],
        );
      },
    );
  }

  Widget _buildBookSection(
    BuildContext context,
    String title,
    List<BibleBookModel> books,
  ) {
    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      initiallyExpanded: title == 'Nuevo Testamento',
      children: books.map((book) {
        return ListTile(
          title: Text(book.name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                // Navega a la pantalla de capítulos
                builder: (context) => BibleChapterScreen(book: book),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// --- Helper Widget: Resultados de Búsqueda (Estado de Búsqueda) ---
class _BibleSearchResults extends ConsumerStatefulWidget {
  final String query;
  const _BibleSearchResults({super.key, required this.query});

  @override
  ConsumerState<_BibleSearchResults> createState() =>
      _BibleSearchResultsState();
}

class _BibleSearchResultsState extends ConsumerState<_BibleSearchResults> {
  String? _chapterId;
  String? _bookName;
  String? _chapterNumber;

  @override
  void initState() {
    super.initState();
    _checkIfVerse();
  }

  /// Verifica si la consulta es un versículo para mostrar el botón "Ver Capítulo".
  Future<void> _checkIfVerse() async {
    // No podemos usar ref.watch() en initState. Usamos ref.read() una vez.
    final bibleService = ref.read(bibleServiceProvider);
    // Usamos el parser del servicio
    final apiRef = await bibleService.parseToApiReference(widget.query);

    if (apiRef != null && apiRef.countMatches('.') == 2) {
      // Es una referencia de versículo, ej: "JHN.3.16"
      final parts = apiRef.split('.');
      final bookId = parts[0];
      final chapNum = parts[1];

      // Necesitamos el nombre del libro (ej. "Juan")
      // `ref.read` aquí es seguro porque el provider ya debe estar resuelto
      // por el widget _BibleBooksList que se carga al inicio.
      final books = await ref.read(bibleBooksProvider.future);
      final allBooks = [
        ...books['Antiguo Testamento']!,
        ...books['Nuevo Testamento']!
      ];
      final book = allBooks.firstWhere((b) => b.id == bookId,
          orElse: () =>
              const BibleBookModel(id: '', name: 'Libro', testament: ''));

      if (mounted) {
        setState(() {
          _chapterId = '$bookId.$chapNum'; // "JHN.3"
          _bookName = book.name; // "Juan"
          _chapterNumber = chapNum; // "3"
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ahora SÍ podemos usar ref.watch()
    final contentAsync = ref.watch(bibleSearchProvider(widget.query));

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error en la búsqueda: $err')),
      data: (content) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CUMPLE TU USER STORY #3 ---
              // Si detectamos que era un versículo, mostramos el botón.
              if (_chapterId != null)
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(
                      'Ver ${_bookName ?? 'Capítulo'} ${_chapterNumber ?? ''} completo'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (_chapterId == null ||
                        _bookName == null ||
                        _chapterNumber == null) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BibleReaderScreen(
                          chapterId: _chapterId!,
                          bookName: _bookName!,
                          chapterNumber: _chapterNumber!,
                        ),
                      ),
                    );
                  },
                ),
              const Divider(),
              // ---
              SelectableText(
                content,
                style: const TextStyle(fontSize: 17, height: 1.6),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Extensión de helper para contar ocurrencias
extension StringCount on String {
  int countMatches(String char) {
    return split(char).length - 1;
  }
}
