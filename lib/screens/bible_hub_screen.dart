// lib/screens/bible_hub_screen.dart
import 'package:flutter/material.dart';
import '../services/bible_service.dart';
import 'bible_search_screen.dart';
import 'bible_books_screen.dart';

/// BibleHubScreen
///
/// Pantalla principal de la sección Biblia con navegación de libros y búsqueda
/// integrada. Implementa una búsqueda inline (minimalista) que muestra
/// sugerencias y resultados sin navegar a una pantalla separada.
class BibleHubScreen extends StatefulWidget {
  const BibleHubScreen({super.key});

  @override
  State<BibleHubScreen> createState() => _BibleHubScreenState();
}

class _BibleHubScreenState extends State<BibleHubScreen>
    with SingleTickerProviderStateMixin {
  final BibleService _bibleService = BibleService();
  final TextEditingController _inlineController = TextEditingController();
  final FocusNode _inlineFocus = FocusNode();
  List<String> _suggestions = [];
  bool _showInline = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inlineController.dispose();
    _inlineFocus.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _onInlineChanged(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    try {
      final s = await _bibleService.getBookSuggestions(q, limit: 6);
      setState(() {
        _suggestions = s;
      });
    } catch (_) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _submitInline(String q) async {
    if (q.trim().isEmpty) return;
    // Cierra teclado
    _inlineFocus.unfocus();

    // Muestra results en modal bottom sheet para comportamiento integrado
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: FutureBuilder<String>(
                  future: _bibleService.searchOrFetch(q),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text('Error: ${snapshot.error}'),
                          ],
                        ),
                      );
                    }
                    final content =
                        snapshot.data ?? 'No se encontraron resultados.';
                    return SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Resultados',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(q,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(content, textAlign: TextAlign.justify),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Santa Biblia (RVR09)'),
          actions: [
            // Minimal search icon that expands an inline search field
            IconButton(
              tooltip: 'Buscar',
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showInline = !_showInline;
                  if (_showInline) {
                    _inlineFocus.requestFocus();
                    _tabController?.animateTo(1);
                  }
                });
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_showInline ? 120.0 : 48.0),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.menu_book), text: 'Navegar'),
                    Tab(icon: Icon(Icons.search), text: 'Buscar'),
                  ],
                ),
                if (_showInline)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _inlineController,
                                focusNode: _inlineFocus,
                                textInputAction: TextInputAction.search,
                                onChanged: _onInlineChanged,
                                onSubmitted: _submitInline,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Buscar libro, capítulo o texto...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_showInline && _suggestions.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        return ActionChip(
                          label: Text(s),
                          onPressed: () {
                            _inlineController.text = s;
                            _submitInline(s);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Pestaña 1: La nueva lista de libros
            BibleBooksScreen(),

            // Pestaña 2: Tu pantalla de búsqueda reutilizada
            BibleSearchScreen(),
          ],
        ),
      ),
    );
  }
}
