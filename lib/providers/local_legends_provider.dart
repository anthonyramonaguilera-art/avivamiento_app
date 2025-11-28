// lib/providers/local_legends_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider de leyendas locales (no depende de base de datos).
/// Las leyendas están hardcodeadas en la app.
final localLegendsProvider = Provider<List<EventLegend>>((ref) {
  return AppConstants.defaultLegends.map((legendData) {
    return EventLegend(
      id: legendData['name']!.toLowerCase().replaceAll(' ', '_'),
      name: legendData['name']!,
      colorHex: legendData['color']!,
      createdBy: 'system',
      createdAt: Timestamp.now(),
    );
  }).toList();
});
