// lib/screens/bible_chapter_screen.dart
import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/bible_book_model.dart';
import 'package:avivamiento_app/models/bible_chapter_model.dart';
import 'package:avivamiento_app/services/bible_service.dart';
import 'package:avivamiento_app/screens/bible_reader_screen.dart';

class BibleChapterScreen extends StatefulWidget {
  final BibleBookModel book;

  const BibleChapterScreen({super.key, required this.book});

  @override
  State<BibleChapterScreen> createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends State<BibleChapterScreen> {
  late Future<List<BibleChapterModel>> _chaptersFuture;
  final BibleService _bibleService = BibleService();

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _bibleService.fetchChapters(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.book.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      body: FutureBuilder<List<BibleChapterModel>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
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
                      'Error al cargar capítulos',
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
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron capítulos.'),
            );
          }

          final chapters = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del libro
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.book.testament == 'OT'
                                ? Colors.blue.shade50
                                : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.book.testament == 'OT'
                                ? 'Antiguo Testamento'
                                : 'Nuevo Testamento',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.book.testament == 'OT'
                                  ? Colors.blue.shade700
                                  : Colors.purple.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${chapters.length} capítulos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Grid de capítulos
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return _ChapterButton(
                      chapter: chapter,
                      book: widget.book,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Botón individual para cada capítulo
class _ChapterButton extends StatelessWidget {
  final BibleChapterModel chapter;
  final BibleBookModel book;

  const _ChapterButton({
    required this.chapter,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BibleReaderScreen(
                chapterId: chapter.id, // Ej: "MAT.5"
                bookName: book.name,
                chapterNumber: chapter.number,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                book.testament == 'OT'
                    ? Colors.blue.shade400
                    : Colors.purple.shade400,
                book.testament == 'OT'
                    ? Colors.blue.shade600
                    : Colors.purple.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (book.testament == 'OT' ? Colors.blue : Colors.purple)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              chapter.number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
