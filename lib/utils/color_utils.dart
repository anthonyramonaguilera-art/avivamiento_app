// lib/utils/color_utils.dart

import 'package:flutter/material.dart';

/// Utilidades para manejo de colores en el calendario.
class ColorUtils {
  /// Convierte un string hexadecimal a Color de Flutter.
  /// Formato esperado: '#RRGGBB' o 'RRGGBB'
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convierte un Color de Flutter a string hexadecimal.
  /// Retorna formato: '#RRGGBB'
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Obtiene un gradiente para mostrar múltiples eventos en un día.
  /// Retorna una lista de colores para crear un gradiente lineal.
  static List<Color> getDivisionColors(List<Color> colors) {
    if (colors.isEmpty) return [Colors.grey.shade300];
    if (colors.length == 1) return colors;
    return colors;
  }

  /// Crea un gradiente lineal para múltiples eventos.
  static LinearGradient createEventGradient(List<Color> colors) {
    if (colors.isEmpty) {
      return LinearGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade300],
      );
    }
    if (colors.length == 1) {
      return LinearGradient(
        colors: [colors[0], colors[0]],
      );
    }

    // Para 2 eventos: división vertical 50/50
    // Para 3+ eventos: división equitativa
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: _calculateStops(colors.length),
    );
  }

  /// Calcula los stops para el gradiente según el número de colores.
  static List<double> _calculateStops(int colorCount) {
    if (colorCount <= 1) return [0.0, 1.0];

    final stops = <double>[];
    for (int i = 0; i < colorCount; i++) {
      stops.add(i / (colorCount - 1));
    }
    return stops;
  }

  /// Obtiene un color más claro para fondos sutiles.
  static Color getLightColor(Color color, {double opacity = 0.15}) {
    return color.withOpacity(opacity);
  }

  /// Obtiene un color más oscuro para bordes o énfasis.
  static Color getDarkColor(Color color) {
    return Color.fromRGBO(
      (color.red * 0.7).round(),
      (color.green * 0.7).round(),
      (color.blue * 0.7).round(),
      1.0,
    );
  }
}
