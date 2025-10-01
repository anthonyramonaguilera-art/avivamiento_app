// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

// Este widget lo crearemos en el futuro para una mejor UI
// import 'widgets/event_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsyncValue = ref.watch(eventsProvider);

    return eventsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error al cargar eventos: $error')),
      data: (events) {
        if (events.isEmpty) {
          return const Center(child: Text('No hay eventos programados.'));
        }

        // Usamos un ListView simple por ahora
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(
                  '${event.location}\n${event.startTime.toDate().toLocal()}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
