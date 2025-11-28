// lib/services/backend/event_backend.dart

import 'package:avivamiento_app/models/event_model.dart';

/// Interfaz abstracta para el backend de eventos.
/// Permite cambiar entre Firestore y AWS sin modificar la lógica de negocio.
abstract class EventBackend {
  /// Obtiene un stream de todos los eventos.
  Stream<List<EventModel>> getEventsStream();

  /// Obtiene eventos de un mes específico.
  Future<List<EventModel>> getEventsForMonth(int year, int month);

  /// Obtiene eventos de un día específico.
  Future<List<EventModel>> getEventsForDay(DateTime day);

  /// Crea un nuevo evento.
  Future<void> createEvent(Map<String, dynamic> eventData);

  /// Actualiza un evento existente.
  Future<void> updateEvent(String eventId, Map<String, dynamic> data);

  /// Elimina un evento.
  Future<void> deleteEvent(String eventId);
}
