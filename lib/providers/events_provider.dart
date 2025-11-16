// lib/providers/events_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que expone la lista de eventos en tiempo real.
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getEventsStream();
});
