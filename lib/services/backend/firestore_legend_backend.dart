// lib/services/backend/firestore_legend_backend.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/services/backend/legend_backend.dart';
import 'package:avivamiento_app/utils/constants.dart';

/// Implementación de LegendBackend usando Firestore.
class FirestoreLegendBackend implements LegendBackend {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _legendsCollection;

  FirestoreLegendBackend(this._firestore) {
    _legendsCollection = _firestore.collection('event_legends');
  }

  @override
  Stream<List<EventLegend>> getLegendsStream() {
    return _legendsCollection.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventLegend.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> createLegend(Map<String, dynamic> legendData) {
    return _legendsCollection.add(legendData);
  }

  @override
  Future<void> updateLegend(String legendId, Map<String, dynamic> data) {
    return _legendsCollection.doc(legendId).update(data);
  }

  @override
  Future<void> deleteLegend(String legendId) {
    return _legendsCollection.doc(legendId).delete();
  }

  @override
  Future<bool> legendExists(String name) async {
    final snapshot =
        await _legendsCollection.where('name', isEqualTo: name).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<EventLegend?> getLegendByName(String name) async {
    final snapshot =
        await _legendsCollection.where('name', isEqualTo: name).limit(1).get();

    if (snapshot.docs.isEmpty) return null;
    return EventLegend.fromMap(
        snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  @override
  Future<void> initializeDefaultLegends(String adminUserId) async {
    final snapshot = await _legendsCollection.limit(1).get();

    // Si ya existen leyendas, no hacer nada
    if (snapshot.docs.isNotEmpty) return;

    // Crear las leyendas predeterminadas
    for (final legend in AppConstants.defaultLegends) {
      await createLegend({
        'name': legend['name']!,
        'colorHex': legend['color']!,
        'createdBy': adminUserId,
        'createdAt': Timestamp.now(),
      });
    }
  }
}
