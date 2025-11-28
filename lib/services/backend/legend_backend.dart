// lib/services/backend/legend_backend.dart

import 'package:avivamiento_app/models/event_legend_model.dart';

/// Interfaz abstracta para el backend de leyendas.
/// Permite cambiar entre Firestore y AWS sin modificar la lógica de negocio.
abstract class LegendBackend {
  /// Obtiene un stream de todas las leyendas.
  Stream<List<EventLegend>> getLegendsStream();

  /// Crea una nueva leyenda.
  Future<void> createLegend(Map<String, dynamic> legendData);

  /// Actualiza una leyenda existente.
  Future<void> updateLegend(String legendId, Map<String, dynamic> data);

  /// Elimina una leyenda.
  Future<void> deleteLegend(String legendId);

  /// Verifica si una leyenda existe por nombre.
  Future<bool> legendExists(String name);

  /// Obtiene una leyenda por nombre.
  Future<EventLegend?> getLegendByName(String name);

  /// Inicializa las leyendas predeterminadas.
  Future<void> initializeDefaultLegends(String adminUserId);
}
