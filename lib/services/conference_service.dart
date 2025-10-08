// lib/services/conference_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/conference_room_model.dart';

/// Servicio para gestionar las operaciones de las salas de conferencia en Firestore.
class ConferenceService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _conferenceCollection;

  ConferenceService(this._firestore) {
    _conferenceCollection = _firestore.collection('conferenceRooms');
  }

  /// Obtiene un Stream de la lista de salas de conferencia.
  Stream<List<ConferenceRoomModel>> getConferenceRoomsStream() {
    return _conferenceCollection
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConferenceRoomModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// [NUEVO] Crea un nuevo documento de sala de conferencia en Firestore.
  Future<void> createConferenceRoom({
    required String topic,
    required String jitsiRoomName,
    required String accessType,
    required List<String> allowedRoles,
  }) {
    return _conferenceCollection.add({
      'topic': topic,
      'jitsiRoomName': jitsiRoomName,
      'accessType': accessType,
      'allowedRoles': allowedRoles,
      // Usamos la fecha del servidor para asegurar consistencia.
      'creationDate': FieldValue.serverTimestamp(),
      // La fecha programada también se guarda, la usaremos más adelante.
      'scheduledDate': FieldValue.serverTimestamp(),
    });
  }
}