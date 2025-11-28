// lib/models/bible_verse_model.dart

/// Modelo para representar un versículo individual de la Biblia.
/// Incluye metadata para futuras características como resaltado y marcadores.
class BibleVerseModel {
  /// Identificador único del versículo (ej: "JHN.3.16")
  final String id;

  /// Número del versículo dentro del capítulo
  final int number;

  /// Texto completo del versículo
  final String text;

  /// Si el versículo está resaltado por el usuario
  final bool isHighlighted;

  /// Si el versículo está marcado como favorito
  final bool isBookmarked;

  const BibleVerseModel({
    required this.id,
    required this.number,
    required this.text,
    this.isHighlighted = false,
    this.isBookmarked = false,
  });

  /// Crea una copia del modelo con valores actualizados
  BibleVerseModel copyWith({
    String? id,
    int? number,
    String? text,
    bool? isHighlighted,
    bool? isBookmarked,
  }) {
    return BibleVerseModel(
      id: id ?? this.id,
      number: number ?? this.number,
      text: text ?? this.text,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  /// Convierte el modelo a un Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'text': text,
      'isHighlighted': isHighlighted,
      'isBookmarked': isBookmarked,
    };
  }

  /// Crea un modelo desde un Map
  factory BibleVerseModel.fromMap(Map<String, dynamic> map) {
    return BibleVerseModel(
      id: map['id'] as String? ?? '',
      number: map['number'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      isHighlighted: map['isHighlighted'] as bool? ?? false,
      isBookmarked: map['isBookmarked'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'BibleVerseModel(id: $id, number: $number, text: ${text.substring(0, text.length > 30 ? 30 : text.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BibleVerseModel &&
        other.id == id &&
        other.number == number &&
        other.text == text &&
        other.isHighlighted == isHighlighted &&
        other.isBookmarked == isBookmarked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        number.hashCode ^
        text.hashCode ^
        isHighlighted.hashCode ^
        isBookmarked.hashCode;
  }
}
