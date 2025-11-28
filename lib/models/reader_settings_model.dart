// lib/models/reader_settings_model.dart

import 'package:flutter/material.dart';

/// Temas disponibles para el lector bíblico
enum ReaderTheme {
  white,
  sepia,
  darkOled;

  /// Obtiene el color de fondo según el tema
  Color get backgroundColor {
    switch (this) {
      case ReaderTheme.white:
        return const Color(0xFFFFFFFF);
      case ReaderTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderTheme.darkOled:
        return const Color(0xFF000000);
    }
  }

  /// Obtiene el color del texto según el tema
  Color get textColor {
    switch (this) {
      case ReaderTheme.white:
        return const Color(0xFF000000);
      case ReaderTheme.sepia:
        return const Color(0xFF5B4636);
      case ReaderTheme.darkOled:
        return const Color(0xFFE0E0E0);
    }
  }

  /// Obtiene el color del AppBar según el tema
  Color get appBarColor {
    switch (this) {
      case ReaderTheme.white:
        return const Color(0xFFF5F5F5);
      case ReaderTheme.sepia:
        return const Color(0xFFE8DCC8);
      case ReaderTheme.darkOled:
        return const Color(0xFF121212);
    }
  }

  /// Obtiene el nombre legible del tema
  String get displayName {
    switch (this) {
      case ReaderTheme.white:
        return 'Blanco';
      case ReaderTheme.sepia:
        return 'Sepia';
      case ReaderTheme.darkOled:
        return 'Oscuro';
    }
  }
}

/// Familias de fuentes disponibles para el lector
enum ReaderFontFamily {
  sansSerif,
  serif;

  /// Obtiene el nombre de la fuente para Flutter
  String get fontFamily {
    switch (this) {
      case ReaderFontFamily.sansSerif:
        return 'Roboto';
      case ReaderFontFamily.serif:
        return 'Georgia';
    }
  }

  /// Obtiene el nombre legible de la familia de fuente
  String get displayName {
    switch (this) {
      case ReaderFontFamily.sansSerif:
        return 'Sans Serif';
      case ReaderFontFamily.serif:
        return 'Serif';
    }
  }
}

/// Modelo para la configuración del lector bíblico
class ReaderSettingsModel {
  /// Tamaño de fuente (entre 14 y 30)
  final double fontSize;

  /// Tema visual del lector
  final ReaderTheme theme;

  /// Familia de fuente
  final ReaderFontFamily fontFamily;

  const ReaderSettingsModel({
    this.fontSize = 18.0,
    this.theme = ReaderTheme.white,
    this.fontFamily = ReaderFontFamily.serif,
  });

  /// Crea una copia del modelo con valores actualizados
  ReaderSettingsModel copyWith({
    double? fontSize,
    ReaderTheme? theme,
    ReaderFontFamily? fontFamily,
  }) {
    return ReaderSettingsModel(
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  /// Convierte el modelo a un Map para persistencia
  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'theme': theme.name,
      'fontFamily': fontFamily.name,
    };
  }

  /// Crea un modelo desde un Map
  factory ReaderSettingsModel.fromMap(Map<String, dynamic> map) {
    return ReaderSettingsModel(
      fontSize: map['fontSize'] as double? ?? 18.0,
      theme: ReaderTheme.values.firstWhere(
        (e) => e.name == map['theme'],
        orElse: () => ReaderTheme.white,
      ),
      fontFamily: ReaderFontFamily.values.firstWhere(
        (e) => e.name == map['fontFamily'],
        orElse: () => ReaderFontFamily.serif,
      ),
    );
  }

  @override
  String toString() {
    return 'ReaderSettingsModel(fontSize: $fontSize, theme: ${theme.name}, fontFamily: ${fontFamily.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReaderSettingsModel &&
        other.fontSize == fontSize &&
        other.theme == theme &&
        other.fontFamily == fontFamily;
  }

  @override
  int get hashCode {
    return fontSize.hashCode ^ theme.hashCode ^ fontFamily.hashCode;
  }
}
