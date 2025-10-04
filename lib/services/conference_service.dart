// lib/services/conference_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/conference_room_model.dart';

/// Servicio para gestionar las operaciones de las salas de conferencias en Firestore.
class ConferenceService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _roomsCollection;

  ConferenceService(this._firestore) {
    _roomsCollection = _firestore.collection('conferenceRooms');
  }

  /// Obtiene un Stream con la lista de las próximas salas de conferencias.
  ///
  /// Se ordena por fecha para mostrar primero las más cercanas en el tiempo.
  Stream<List<ConferenceRoomModel>> getConferenceRoomsStream() {
    return _roomsCollection
        .orderBy(
          'scheduledDate',
          descending: false,
        ) // Muestra las próximas primero
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ConferenceRoomModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
