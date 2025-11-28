// lib/services/editable_legends_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';

/// Servicio para gestionar leyendas editables en Firestore.
class EditableLegendsService {
  final FirebaseFirestore _firestore;

  EditableLegendsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtener todas las leyendas
  Stream<List<EventLegend>> getLegendsStream() {
    return _firestore
        .collection('event_legends')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventLegend.fromFirestore(doc))
          .toList();
    });
  }

  /// Crear una nueva leyenda
  Future<String> createLegend({
    required String name,
    required String colorHex,
    required String createdBy,
  }) async {
    final docRef = await _firestore.collection('event_legends').add({
      'name': name,
      'colorHex': colorHex,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Actualizar una leyenda existente
  Future<void> updateLegend({
    required String id,
    required String name,
    required String colorHex,
  }) async {
    await _firestore.collection('event_legends').doc(id).update({
      'name': name,
      'colorHex': colorHex,
    });
  }

  /// Eliminar una leyenda
  Future<void> deleteLegend(String id) async {
    await _firestore.collection('event_legends').doc(id).delete();
  }

  /// Inicializar leyendas predeterminadas si no existen
  Future<void> initializeDefaultLegends({
    required List<Map<String, String>> defaultLegends,
    required String createdBy,
  }) async {
    final snapshot =
        await _firestore.collection('event_legends').limit(1).get();

    if (snapshot.docs.isEmpty) {
      // No hay leyendas, crear las predeterminadas
      final batch = _firestore.batch();

      for (final legend in defaultLegends) {
        final docRef = _firestore.collection('event_legends').doc();
        batch.set(docRef, {
          'name': legend['name'],
          'colorHex': legend['color'],
          'createdBy': createdBy,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }
  }
}
