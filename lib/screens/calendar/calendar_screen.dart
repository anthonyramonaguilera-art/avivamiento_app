// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/events_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/screens/calendar/create_event_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsyncValue = ref.watch(eventsProvider);
    final userProfile = ref.watch(userProfileProvider);

    final bool isAdmin = userProfile.when(
      data: (user) => user?.rol == 'Pastor' || user?.rol == 'Líder',
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      body: eventsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar eventos: $error')),
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No hay eventos programados.'));
          }
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
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              // [CORRECCIÓN] Añadimos un tag único diferente al del feed
              heroTag: 'add_event_button',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
