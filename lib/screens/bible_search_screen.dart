// lib/screens/bible_search_screen.dart
import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class BibleSearchScreen extends StatefulWidget {
  static const String routeName = '/bible-search';

  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BibleService _bibleService = BibleService();
  final _formKey = GlobalKey<FormState>();
  String _bibleContent =
      'Ingresa una referencia (ej: Juan 3:16) o una palabra clave para buscar.';
  bool _isLoading = false;
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _allBookNames = [];

  @override
  void initState() {
    super.initState();
    _loadInitialContent();
    _loadBookNames();
  }

  Future<void> _loadBookNames() async {
    try {
      final names = await _bibleService.getAllBookNames();
      setState(() {
        _allBookNames = names;
      });
    } catch (e) {
      // ignore - suggestions will fallback to static list
    }
  }

  Future<void> _loadInitialContent() async {
    // Cargar un versículo por defecto al iniciar
    _fetchContent('Juan 3:16');
  }

  Future<void> _fetchContent(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _bibleContent =
            'Por favor, ingresa una referencia o una palabra clave.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
      _bibleContent = 'Buscando...';
    });

    try {
      // Use the smarter parser that accepts human formats (e.g. "Juan 3:16")
      final content = await _bibleService.searchOrFetch(query);
      setState(() {
        _bibleContent = content;
      });
    } catch (e) {
      setState(() {
        _bibleContent = 'Error al buscar "$query": $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) async {
    if (query.trim().isNotEmpty) {
      // Use book suggestions from service when available, otherwise fallback to static list
      List<String> suggestions = [];
      try {
        suggestions = await _bibleService.getBookSuggestions(query, limit: 8);
      } catch (_) {
        // fallback to local loaded names
        if (_allBookNames.isNotEmpty) {
          suggestions = _allBookNames
              .where((n) => n.toLowerCase().contains(query.toLowerCase()))
              .take(8)
              .toList();
        } else {
          suggestions = [];
        }
      }

      // Also include a few common reference suggestions if the user typed a number or letter
      final staticHints = [
        'Génesis 1:1',
        'Salmos 23:1',
        'Mateo 28:19',
        'Juan 14:6',
        'Romanos 8:28',
        '1 Corintios 13',
        'Apocalipsis 21:4'
      ];

      final merged = <String>[];
      merged.addAll(suggestions.map((s) => s));
      for (var h in staticHints) {
        if (h.toLowerCase().contains(query.toLowerCase()) &&
            !merged.contains(h)) {
          merged.add(h);
        }
      }

      setState(() {
        _suggestions = merged;
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title:
            const Text('Biblia', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // Ocultar el teclado cuando se toca fuera del campo de búsqueda
            FocusScope.of(context).unfocus();
            setState(() {
              _showSuggestions = false;
            });
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              children: [
                // Barra de búsqueda (Form)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de búsqueda con validación
                        TextFormField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar en la Biblia...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            _onSearchChanged(v);
                          },
                          onFieldSubmitted: (value) async {
                            // Validate and then submit
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _showSuggestions = false;
                            });
                            // Try to parse reference; if parse fails, we still perform a text search
                            final parsed =
                                await _bibleService.parseToApiReference(value);
                            if (parsed == null) {
                              // show a subtle suggestion: attempt text search
                              _fetchContent(value);
                              final sugg =
                                  await _bibleService.getBookSuggestions(value);
                              if (sugg.isNotEmpty) {
                                setState(() {
                                  _suggestions = sugg;
                                  _showSuggestions = true;
                                });
                              }
                            } else {
                              _fetchContent(value);
                            }
                          },
                          onTap: () {
                            setState(() {
                              _showSuggestions = _suggestions.isNotEmpty &&
                                  _searchController.text.isNotEmpty;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // empty allowed until submit
                            }
                            // Don't block submission; we validate on submit with parse
                            return null;
                          },
                        ),

                        // Sugerencias de búsqueda (bounded height)
                        if (_showSuggestions && _suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      _suggestions[index],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    leading: const Icon(Icons.bookmark_border,
                                        size: 20, color: Colors.grey),
                                    onTap: () {
                                      _searchController.text =
                                          _suggestions[index];
                                      _fetchContent(_suggestions[index]);
                                      setState(() {
                                        _showSuggestions = false;
                                      });
                                      _searchFocusNode.unfocus();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Contenido bíblico
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ),
                              SizedBox(height: 16),
                              Text('Buscando en la Biblia...',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                              20.0, 20.0, 20.0, bottomInset + 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isLoading &&
                                  _searchController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    _searchController.text,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              Text(
                                _bibleContent,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  height: 1.8,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
