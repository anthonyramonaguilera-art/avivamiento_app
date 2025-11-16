// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/providers/events_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/screens/calendar/create_event_screen.dart';
import 'package:avivamiento_app/screens/calendar/edit_event_screen.dart';
import 'package:avivamiento_app/utils/constants.dart';

enum EventStatus { upcoming, ongoing, finished }

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  EventStatus _getEventStatus(EventModel event) {
    final now = DateTime.now();
    final startTime = event.startTime.toDate();
    final endTime = event.endTime.toDate();

    if (now.isAfter(endTime)) {
      return EventStatus.finished;
    } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return EventStatus.ongoing;
    } else {
      return EventStatus.upcoming;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsyncValue = ref.watch(eventsProvider);
    final userProfile = ref.watch(userProfileProvider).value;

    final bool canManageEvents = userProfile != null &&
        [
          AppConstants.rolePastor,
          AppConstants.roleAdmin,
          AppConstants.roleLider
        ].contains(userProfile.rol);

    return Scaffold(
      body: eventsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No hay eventos programados.'));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final status = _getEventStatus(event);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // [CAMBIO] La opacidad se aplica a toda la tarjeta si ha finalizado.
                child: Opacity(
                  opacity: status == EventStatus.finished ? 0.6 : 1.0,
                  child: ListTile(
                    leading:
                        _buildStatusIndicator(status), // Indicador de estado
                    title: Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormat.yMd().add_jm().format(event.startTime.toDate())}\n${event.location}',
                    ),
                    isThreeLine: true,
                    trailing: canManageEvents
                        ? _buildAdminMenu(context, ref, event)
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canManageEvents
          ? FloatingActionButton(
              heroTag: 'add_event_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // [NUEVO] Widget para el indicador visual con ícono y texto.
  Widget _buildStatusIndicator(EventStatus status) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case EventStatus.ongoing:
        icon = Icons.sync_alt;
        color = Colors.green.shade700;
        text = 'En Proceso';
        break;
      case EventStatus.upcoming:
        icon = Icons.update;
        color = Colors.blue.shade700;
        text = 'Próximo';
        break;
      case EventStatus.finished:
        icon = Icons.check_circle_outline;
        color = Colors.grey.shade600;
        text = 'Finalizado';
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }

  // El resto de los métodos (_buildAdminMenu y _showDeleteConfirmation) no cambian.
  // ... (pegar aquí los métodos _buildAdminMenu y _showDeleteConfirmation de la respuesta anterior)
  Widget _buildAdminMenu(
      BuildContext context, WidgetRef ref, EventModel event) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditEventScreen(event: event)),
          );
        } else if (value == 'delete') {
          _showDeleteConfirmation(context, ref, event);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Eliminar', style: TextStyle(color: Colors.red))),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Estás seguro de que quieres eliminar el evento "${event.title}"?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(eventServiceProvider).deleteEvent(event.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evento eliminado con éxito')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
