// lib/services/event_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _eventsCollection;

  EventService(this._firestore) {
    _eventsCollection = _firestore.collection('events');
  }

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

  /// **[NUEVO]** Crea un nuevo documento de evento en Firestore.
  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required Timestamp startTime,
    required Timestamp endTime,
  }) {
    return _eventsCollection.add({
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
    });
  }
}
