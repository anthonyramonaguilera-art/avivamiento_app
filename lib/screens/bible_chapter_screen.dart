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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
      ),
      body: FutureBuilder<List<BibleChapterModel>>(
        future: _chaptersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar capítulos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron capítulos.'));
          }

          final chapters = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ElevatedButton(
                child: Text(chapter.number),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BibleReaderScreen(
                        chapterId: chapter.id, // Ej: "MAT.5"
                        bookName: widget.book.name,
                        chapterNumber: chapter.number,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
