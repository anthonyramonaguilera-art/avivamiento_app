// lib/services/backend/firestore_event_backend.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/services/backend/event_backend.dart';

/// Implementación de EventBackend usando Firestore.
class FirestoreEventBackend implements EventBackend {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _eventsCollection;

  FirestoreEventBackend(this._firestore) {
    _eventsCollection = _firestore.collection('events');
  }

  @override
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

  @override
  Future<List<EventModel>> getEventsForMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _eventsCollection
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    return snapshot.docs.map((doc) {
      return EventModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<List<EventModel>> getEventsForDay(DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    final snapshot = await _eventsCollection
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) {
      return EventModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<void> createEvent(Map<String, dynamic> eventData) {
    return _eventsCollection.add(eventData);
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) {
    return _eventsCollection.doc(eventId).update(data);
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _eventsCollection.doc(eventId).delete();
  }
}
