// lib/models/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo de datos para eventos del calendario.
/// Incluye soporte para leyendas, roles objetivo, y visibilidad basada en permisos.
class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final Timestamp startTime;
  final Timestamp endTime;

  // Campos de leyenda
  final String legendName;
  final String legendColor; // Color en formato hex (#RRGGBB)

  // Roles que pueden ver este evento
  final List<String> targetRoles;

  // Imagen opcional del evento
  final String? imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.legendName,
    required this.legendColor,
    required this.targetRoles,
    this.imageUrl,
  });

  /// Factory constructor para crear una instancia desde Firestore
  factory EventModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EventModel(
      id: documentId,
      title: data['title'] ?? 'Sin Título',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      legendName: data['legendName'] ?? 'Otros',
      legendColor: data['legendColor'] ?? '#FFC107',
      targetRoles: List<String>.from(data['targetRoles'] ?? ['Todos']),
      imageUrl: data['imageUrl'],
    );
  }

  /// Convierte la instancia a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'legendName': legendName,
      'legendColor': legendColor,
      'targetRoles': targetRoles,
      'imageUrl': imageUrl,
    };
  }

  /// Verifica si un usuario con el rol dado puede ver este evento
  bool isVisibleForRole(String userRole) {
    // Si el evento es para "Todos", cualquiera puede verlo
    if (targetRoles.contains('Todos')) return true;

    // Admin y Pastor pueden ver todos los eventos
    if (userRole == 'Admin' || userRole == 'Pastor') return true;

    // Verificar si el rol del usuario está en la lista de roles objetivo
    return targetRoles.contains(userRole);
  }

  /// Verifica si un usuario puede gestionar (editar/eliminar) este evento
  bool canUserManage(String userRole) {
    return userRole == 'Admin' || userRole == 'Pastor' || userRole == 'Líder';
  }

  /// Convierte el color hex a Color de Flutter
  Color get color {
    final hexColor = legendColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  /// Obtiene la fecha del evento (sin hora)
  DateTime get eventDate {
    final dt = startTime.toDate();
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Copia el evento con campos modificados
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    Timestamp? startTime,
    Timestamp? endTime,
    String? legendName,
    String? legendColor,
    List<String>? targetRoles,
    String? imageUrl,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      legendName: legendName ?? this.legendName,
      legendColor: legendColor ?? this.legendColor,
      targetRoles: targetRoles ?? this.targetRoles,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
