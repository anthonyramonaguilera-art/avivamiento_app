// lib/screens/bible_books_screen.dart
import 'package:flutter/material.dart';
import '../models/bible_book_model.dart';
import '../services/bible_service.dart';
import 'bible_chapter_screen.dart';

class BibleBooksScreen extends StatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  State<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends State<BibleBooksScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, List<BibleBookModel>>> _booksFuture;
  late TabController _tabController;
  final BibleService _bibleService = BibleService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchAndGroupBooks();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, List<BibleBookModel>>> _fetchAndGroupBooks() async {
    final books = await _bibleService.fetchBooks();
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
  }

  List<BibleBookModel> _filterBooks(List<BibleBookModel> books) {
    if (_searchQuery.isEmpty) return books;

    return books.where((book) {
      return book.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, List<BibleBookModel>>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Santa Biblia')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar libros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('No se encontraron libros.')),
          );
        }

        final groupedBooks = snapshot.data!;
        final otBooks = groupedBooks['Antiguo Testamento']!;
        final ntBooks = groupedBooks['Nuevo Testamento']!;

        final filteredOT = _filterBooks(otBooks);
        final filteredNT = _filterBooks(ntBooks);

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  elevation: 0,
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  title: const Text(
                    'Santa Biblia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(110),
                    child: Column(
                      children: [
                        // Barra de búsqueda
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar libro...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        // TabBar
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          tabs: [
                            Tab(
                              text: 'Antiguo T. (${filteredOT.length})',
                            ),
                            Tab(
                              text: 'Nuevo T. (${filteredNT.length})',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildBooksList(filteredOT, 'OT'),
                _buildBooksList(filteredNT, 'NT'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBooksList(List<BibleBookModel> books, String testament) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron libros',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookCard(book: book);
      },
    );
  }
}

/// Card individual para cada libro
class _BookCard extends StatelessWidget {
  final BibleBookModel book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BibleChapterScreen(book: book),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono del libro
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: book.testament == 'OT'
                          ? [Colors.blue.shade400, Colors.blue.shade600]
                          : [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Nombre del libro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.testament == 'OT'
                            ? 'Antiguo Testamento'
                            : 'Nuevo Testamento',
                        style: TextStyle(
                          fontSize: 12,
                          color: book.testament == 'OT'
                              ? Colors.blue.shade600
                              : Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
