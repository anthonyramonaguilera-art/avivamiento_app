// lib/providers/bible_navigation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Estado de navegación del lector bíblico
class BibleNavigationState {
  final String bookId;
  final String bookName;
  final int chapterNumber;
  final int totalChapters;
  final bool isLoading;
  final String? error;

  const BibleNavigationState({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.totalChapters,
    this.isLoading = false,
    this.error,
  });

  BibleNavigationState copyWith({
    String? bookId,
    String? bookName,
    int? chapterNumber,
    int? totalChapters,
    bool? isLoading,
    String? error,
  }) {
    return BibleNavigationState(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      totalChapters: totalChapters ?? this.totalChapters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Identificador del capítulo actual (ej: "JHN.3")
  String get chapterId => '$bookId.$chapterNumber';

  /// Verifica si hay un capítulo anterior
  bool get hasPreviousChapter => chapterNumber > 1;

  /// Verifica si hay un capítulo siguiente
  bool get hasNextChapter => chapterNumber < totalChapters;
}

/// StateNotifier para gestionar la navegación entre capítulos
class BibleNavigationNotifier extends StateNotifier<BibleNavigationState> {
  final Ref ref;

  BibleNavigationNotifier(this.ref)
      : super(const BibleNavigationState(
          bookId: '',
          bookName: '',
          chapterNumber: 1,
          totalChapters: 1,
        ));

  /// Inicializa el estado con un capítulo específico
  Future<void> initialize({
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Obtener el total de capítulos del libro
      final bibleService = ref.read(bibleServiceProvider);
      final chapters = await bibleService.fetchChapters(bookId);

      state = BibleNavigationState(
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
        totalChapters: chapters.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar información del libro: $e',
      );
    }
  }

  /// Navega al capítulo siguiente
  Future<bool> nextChapter() async {
    if (!state.hasNextChapter) {
      return false;
    }

    state = state.copyWith(chapterNumber: state.chapterNumber + 1);
    return true;
  }

  /// Navega al capítulo anterior
  Future<bool> previousChapter() async {
    if (!state.hasPreviousChapter) {
      return false;
    }

    state = state.copyWith(chapterNumber: state.chapterNumber - 1);
    return true;
  }

  /// Navega a un capítulo específico
  Future<bool> goToChapter(int chapterNumber) async {
    if (chapterNumber < 1 || chapterNumber > state.totalChapters) {
      return false;
    }

    state = state.copyWith(chapterNumber: chapterNumber);
    return true;
  }

  /// Cambia a un libro diferente
  Future<void> changeBook({
    required String bookId,
    required String bookName,
    int chapterNumber = 1,
  }) async {
    await initialize(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
    );
  }
}

/// Provider para la navegación del lector bíblico
final bibleNavigationProvider =
    StateNotifierProvider<BibleNavigationNotifier, BibleNavigationState>(
  (ref) => BibleNavigationNotifier(ref),
);
