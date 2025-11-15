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

class _BibleBooksScreenState extends State<BibleBooksScreen> {
  late Future<Map<String, List<BibleBookModel>>> _booksFuture;
  final BibleService _bibleService = BibleService();

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchAndGroupBooks();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<BibleBookModel>>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error al cargar libros: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron libros.'));
        }

        final groupedBooks = snapshot.data!;
        final otBooks = groupedBooks['Antiguo Testamento']!;
        final ntBooks = groupedBooks['Nuevo Testamento']!;

        return ListView(
          children: [
            _buildBookSection(context, 'Antiguo Testamento', otBooks),
            _buildBookSection(context, 'Nuevo Testamento', ntBooks),
          ],
        );
      },
    );
  }

  Widget _buildBookSection(
      BuildContext context, String title, List<BibleBookModel> books) {
    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      initiallyExpanded: true,
      children: books.map((book) {
        return ListTile(
          title: Text(book.name),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BibleChapterScreen(book: book),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
