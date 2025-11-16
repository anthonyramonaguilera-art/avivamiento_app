// lib/screens/bible_reader_screen.dart
import 'package:flutter/material.dart';
import 'package:avivamiento_app/services/bible_service.dart';

class BibleReaderScreen extends StatefulWidget {
  final String chapterId;
  final String bookName;
  final String chapterNumber;

  const BibleReaderScreen({
    super.key,
    required this.chapterId,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  late Future<String> _contentFuture;
  final BibleService _bibleService = BibleService();

  @override
  void initState() {
    super.initState();
    _contentFuture = _bibleService.fetchChapterContent(widget.chapterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} ${widget.chapterNumber}'),
      ),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar contenido: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró contenido.'));
          }

          final content = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SelectableText(
              content,
              style: const TextStyle(
                  fontSize: 18, height: 1.6, fontFamily: 'Georgia'),
            ),
          );
        },
      ),
    );
  }
}
