// lib/services/legend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/services/backend/legend_backend.dart';

/// Servicio de leyendas que usa un backend abstracto.
/// Puede funcionar con Firestore o AWS según la configuración.
class LegendService {
  final LegendBackend _backend;

  LegendService(this._backend);

  /// Obtiene un stream de todas las leyendas.
  Stream<List<EventLegend>> getLegendsStream() {
    return _backend.getLegendsStream();
  }

  /// Crea una nueva leyenda.
  Future<void> createLegend({
    required String name,
    required String colorHex,
    required String createdBy,
  }) {
    return _backend.createLegend({
      'name': name,
      'colorHex': colorHex,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
    });
  }

  /// Actualiza una leyenda existente.
  Future<void> updateLegend(String legendId, Map<String, dynamic> data) {
    return _backend.updateLegend(legendId, data);
  }

  /// Elimina una leyenda.
  Future<void> deleteLegend(String legendId) {
    return _backend.deleteLegend(legendId);
  }

  /// Inicializa las leyendas predeterminadas si no existen.
  Future<void> initializeDefaultLegends(String adminUserId) {
    return _backend.initializeDefaultLegends(adminUserId);
  }

  /// Verifica si una leyenda existe por nombre.
  Future<bool> legendExists(String name) {
    return _backend.legendExists(name);
  }

  /// Obtiene una leyenda por nombre.
  Future<EventLegend?> getLegendByName(String name) {
    return _backend.getLegendByName(name);
  }
}
