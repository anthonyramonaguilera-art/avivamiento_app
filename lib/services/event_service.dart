// lib/services/event_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/services/backend/event_backend.dart';

/// Servicio de eventos que usa un backend abstracto.
/// Puede funcionar con Firestore o AWS según la configuración.
class EventService {
  final EventBackend _backend;

  EventService(this._backend);

  /// Obtiene un stream de todos los eventos ordenados por fecha de inicio.
  Stream<List<EventModel>> getEventsStream() {
    return _backend.getEventsStream();
  }

  /// Obtiene eventos de un mes específico.
  Future<List<EventModel>> getEventsForMonth(int year, int month) {
    return _backend.getEventsForMonth(year, month);
  }

  /// Obtiene eventos de un día específico.
  Future<List<EventModel>> getEventsForDay(DateTime day) {
    return _backend.getEventsForDay(day);
  }

  /// Crea un nuevo evento.
  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required Timestamp startTime,
    required Timestamp endTime,
    required String legendName,
    required String legendColor,
    required List<String> targetRoles,
    String? imageUrl,
  }) {
    return _backend.createEvent({
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'legendName': legendName,
      'legendColor': legendColor,
      'targetRoles': targetRoles,
      'imageUrl': imageUrl,
    });
  }

  /// Actualiza un evento existente.
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) {
    return _backend.updateEvent(eventId, data);
  }

  /// Elimina un evento.
  Future<void> deleteEvent(String eventId) {
    return _backend.deleteEvent(eventId);
  }
}
