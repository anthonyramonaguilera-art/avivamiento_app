// lib/models/event_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para un evento en el calendario.
class EventModel {
  final String id;
  final String title;
  final String description;
  final Timestamp startTime;
  final Timestamp endTime;
  final String location;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  /// Factory para crear una instancia de [EventModel] desde un mapa de Firestore.
  factory EventModel.fromMap(Map<String, dynamic> data, String documentId) {
    return EventModel(
      id: documentId,
      title: data['title'] ?? 'Sin Título',
      description: data['description'] ?? '',
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      location: data['location'] ?? 'Ubicación no especificada',
    );
  }
}
