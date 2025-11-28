// lib/providers/legends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/services/legend_service.dart';
import 'package:avivamiento_app/services/backend/legend_backend.dart';
import 'package:avivamiento_app/services/backend/firestore_legend_backend.dart';

/// Provider del backend de leyendas.
final legendBackendProvider = Provider<LegendBackend>((ref) {
  // Para usar Firestore:
  return FirestoreLegendBackend(FirebaseFirestore.instance);

  // Para usar AWS (descomentar cuando esté listo):
  // return AWSLegendBackend(
  //   apiBaseUrl: 'https://tu-api-gateway-url.amazonaws.com/prod',
  // );
});

/// Provider del servicio de leyendas.
final legendServiceProvider = Provider<LegendService>((ref) {
  return LegendService(ref.watch(legendBackendProvider));
});

/// Provider del stream de leyendas.
final legendsProvider = StreamProvider<List<EventLegend>>((ref) {
  final service = ref.watch(legendServiceProvider);
  return service.getLegendsStream();
});

/// Provider para la leyenda seleccionada en formularios.
final selectedLegendProvider = StateProvider<EventLegend?>((ref) => null);
