// lib/providers/editable_legends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/services/editable_legends_service.dart';
import 'package:avivamiento_app/utils/constants.dart';

/// Provider del servicio de leyendas editables
final editableLegendsServiceProvider = Provider<EditableLegendsService>((ref) {
  return EditableLegendsService();
});

/// Provider de leyendas editables desde Firestore
final editableLegendsProvider = StreamProvider<List<EventLegend>>((ref) {
  final service = ref.watch(editableLegendsServiceProvider);
  return service.getLegendsStream();
});

/// Provider para inicializar leyendas predeterminadas
final initializeLegendsProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(editableLegendsServiceProvider);
  await service.initializeDefaultLegends(
    defaultLegends: AppConstants.defaultLegends,
    createdBy: 'system',
  );
});
