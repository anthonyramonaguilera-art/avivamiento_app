// lib/services/livestream_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/livestream_model.dart';

/// Servicio para gestionar todas las operaciones relacionadas con las transmisiones
/// en la colección 'livestreams' de Firestore.
class LivestreamService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _livestreamsCollection;

  LivestreamService(this._firestore) {
    _livestreamsCollection = _firestore.collection('livestreams');
  }

  /// Obtiene un Stream con la lista de todas las transmisiones.
  ///
  /// Los resultados se ordenan de dos maneras para asegurar que:
  /// 1. La transmisión marcada como "en vivo" (isLive == true) aparezca siempre de primera.
  /// 2. El resto de las transmisiones se ordenen por fecha, de la más reciente a la más antigua.
  Stream<List<LivestreamModel>> getLivestreamsStream() {
    return _livestreamsCollection
        .orderBy(
          'isLive',
          descending: true,
        ) // Prioridad 1: los que están en vivo
        .orderBy(
          'broadcastDate',
          descending: true,
        ) // Prioridad 2: los más recientes
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LivestreamModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
