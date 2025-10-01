// lib/services/event_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_model.dart';

/// Servicio para manejar las operaciones de los eventos del calendario.
class EventService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _eventsCollection;

  EventService(this._firestore) {
    _eventsCollection = _firestore.collection('events');
  }

  /// Obtiene un Stream de la lista de eventos.
  /// Se ordenan por fecha de inicio para mostrar los más próximos primero.
  Stream<List<EventModel>> getEventsStream() {
    return _eventsCollection
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EventModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
