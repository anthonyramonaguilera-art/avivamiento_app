// lib/providers/reader_settings_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avivamiento_app/models/reader_settings_model.dart';

const String _READER_SETTINGS_KEY = 'bible_reader_settings_v1';

/// StateNotifier para gestionar la configuración del lector bíblico
class ReaderSettingsNotifier extends StateNotifier<ReaderSettingsModel> {
  ReaderSettingsNotifier() : super(const ReaderSettingsModel()) {
    _loadSettings();
  }

  /// Carga la configuración desde SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_READER_SETTINGS_KEY);
      if (raw != null && raw.isNotEmpty) {
        final map = json.decode(raw) as Map<String, dynamic>;
        state = ReaderSettingsModel.fromMap(map);
      }
    } catch (e) {
      print('Error cargando configuración del lector: $e');
      // Mantener configuración por defecto
    }
  }

  /// Guarda la configuración en SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = json.encode(state.toMap());
      await prefs.setString(_READER_SETTINGS_KEY, raw);
    } catch (e) {
      print('Error guardando configuración del lector: $e');
    }
  }

  /// Actualiza el tamaño de fuente
  Future<void> updateFontSize(double fontSize) async {
    // Validar rango (14-30)
    final clampedSize = fontSize.clamp(14.0, 30.0);
    state = state.copyWith(fontSize: clampedSize);
    await _saveSettings();
  }

  /// Actualiza el tema visual
  Future<void> updateTheme(ReaderTheme theme) async {
    state = state.copyWith(theme: theme);
    await _saveSettings();
  }

  /// Actualiza la familia de fuente
  Future<void> updateFontFamily(ReaderFontFamily fontFamily) async {
    state = state.copyWith(fontFamily: fontFamily);
    await _saveSettings();
  }

  /// Restablece a la configuración por defecto
  Future<void> reset() async {
    state = const ReaderSettingsModel();
    await _saveSettings();
  }
}

/// Provider para la configuración del lector bíblico
final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettingsModel>(
  (ref) => ReaderSettingsNotifier(),
);
