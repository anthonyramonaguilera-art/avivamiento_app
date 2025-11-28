// lib/models/event_legend_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo para las leyendas/categorías de eventos.
/// Permite crear categorías personalizadas con nombres y colores.
class EventLegend {
  final String id;
  final String name;
  final String colorHex; // Color en formato hex (#RRGGBB)
  final String createdBy; // ID del usuario que creó la leyenda
  final Timestamp createdAt;

  EventLegend({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdBy,
    required this.createdAt,
  });

  /// Factory constructor para crear una instancia desde Firestore
  factory EventLegend.fromMap(Map<String, dynamic> data, String documentId) {
    return EventLegend(
      id: documentId,
      name: data['name'] ?? 'Sin Nombre',
      colorHex: data['colorHex'] ?? '#9E9E9E',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Crear desde documento de Firestore
  factory EventLegend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventLegend(
      id: doc.id,
      name: data['name'] ?? '',
      colorHex: data['colorHex'] ?? '#2196F3',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'colorHex': colorHex,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  /// Convierte el color hex a Color de Flutter
  Color get color {
    final hexColor = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Copia la leyenda con campos modificados
  EventLegend copyWith({
    String? id,
    String? name,
    String? colorHex,
    String? createdBy,
    Timestamp? createdAt,
  }) {
    return EventLegend(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
