// lib/screens/bible_reader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/bible_verse_model.dart';
import 'package:avivamiento_app/models/reader_settings_model.dart';
import 'package:avivamiento_app/providers/bible_navigation_provider.dart';
import 'package:avivamiento_app/providers/reader_settings_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/widgets/reader_settings_modal.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
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
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<BibleVerseModel>> _versesFuture;

  @override
  void initState() {
    super.initState();
    // Inicializar el provider de navegación con los datos del widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookId = widget.chapterId.split('.').first;
      final chapterNum = int.tryParse(widget.chapterNumber) ?? 1;

      ref.read(bibleNavigationProvider.notifier).initialize(
            bookId: bookId,
            bookName: widget.bookName,
            chapterNumber: chapterNum,
          );
    });

    // Carga inicial (usando los datos del widget mientras se inicializa el provider)
    _versesFuture =
        ref.read(bibleServiceProvider).fetchChapterVerses(widget.chapterId);
  }

  void _loadVerses(String chapterId) {
    final bibleService = ref.read(bibleServiceProvider);
    setState(() {
      _versesFuture = bibleService.fetchChapterVerses(chapterId);
    });
    // Volver al inicio del scroll al cambiar de capítulo
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReaderSettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(readerSettingsProvider);
    final navState = ref.watch(bibleNavigationProvider);

    // Escuchar cambios en el capítulo para recargar versículos
    ref.listen(bibleNavigationProvider, (previous, next) {
      if (previous?.chapterId != next.chapterId && !next.isLoading) {
        _loadVerses(next.chapterId);
      }
    });

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: settings.theme.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: settings.theme.appBarColor,
          foregroundColor: settings.theme.textColor,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverAppBar flotante que se oculta al hacer scroll
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: settings.theme.appBarColor,
              foregroundColor: settings.theme.textColor,
              title: Text(
                // Usar el estado de navegación si está listo, sino los datos del widget
                navState.bookName.isNotEmpty
                    ? '${navState.bookName} ${navState.chapterNumber}'
                    : '${widget.bookName} ${widget.chapterNumber}',
                style: TextStyle(
                  color: settings.theme.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: settings.theme.textColor),
                  onPressed: _showSettings,
                  tooltip: 'Configuración del lector',
                ),
              ],
            ),

            // Contenido: versículos
            FutureBuilder<List<BibleVerseModel>>(
              future: _versesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: settings.theme.textColor.withOpacity(0.7),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: settings.theme.textColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar contenido',
                              style: TextStyle(
                                color: settings.theme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: TextStyle(
                                color:
                                    settings.theme.textColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No se encontró contenido.',
                        style: TextStyle(
                          color: settings.theme.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                final verses = snapshot.data!;

                return SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Si es el último ítem, agregar controles de navegación
                        if (index == verses.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Botón Anterior
                                if (navState.hasPreviousChapter)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(
                                              bibleNavigationProvider.notifier)
                                          .previousChapter();
                                    },
                                    icon: const Icon(Icons.arrow_back_ios,
                                        size: 16),
                                    label: const Text('Anterior'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: settings.theme.textColor
                                          .withOpacity(0.1),
                                      foregroundColor: settings.theme.textColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 100), // Espaciador

                                // Botón Siguiente
                                if (navState.hasNextChapter)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(
                                              bibleNavigationProvider.notifier)
                                          .nextChapter();
                                    },
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    label: const Text('Siguiente'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: settings.theme.textColor
                                          .withOpacity(0.1),
                                      foregroundColor: settings.theme.textColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                    // Poner icono a la derecha
                                    iconAlignment: IconAlignment.end,
                                  )
                                else
                                  const SizedBox(width: 100), // Espaciador
                              ],
                            ),
                          );
                        }

                        final verse = verses[index];
                        return _VerseWidget(
                          verse: verse,
                          settings: settings,
                        );
                      },
                      // +1 para los botones de navegación
                      childCount: verses.length + 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget individual para cada versículo
class _VerseWidget extends StatelessWidget {
  final BibleVerseModel verse;
  final ReaderSettingsModel settings;

  const _VerseWidget({
    required this.verse,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SelectableText.rich(
        TextSpan(
          children: [
            // Número del versículo (superíndice pequeño)
            TextSpan(
              text: '${verse.number} ',
              style: TextStyle(
                fontSize: settings.fontSize * 0.65,
                fontWeight: FontWeight.bold,
                color: settings.theme.textColor.withOpacity(0.5),
                fontFamily: settings.fontFamily.fontFamily,
              ),
            ),
            // Texto del versículo
            TextSpan(
              text: verse.text,
              style: TextStyle(
                fontSize: settings.fontSize,
                height: 1.7,
                color: settings.theme.textColor,
                fontFamily: settings.fontFamily.fontFamily,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
