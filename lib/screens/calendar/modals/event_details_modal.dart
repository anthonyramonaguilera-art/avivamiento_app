// lib/screens/calendar/modals/event_details_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/utils/color_utils.dart';
import 'package:avivamiento_app/utils/constants.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/screens/calendar/modals/create_event_modal.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Modal para mostrar los detalles de uno o más eventos de un día.
class EventDetailsModal extends ConsumerWidget {
  final DateTime date;
  final List<EventModel> events;

  const EventDetailsModal({
    super.key,
    required this.date,
    required this.events,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final canManage = userProfile != null &&
        events.isNotEmpty &&
        events.first.canUserManage(userProfile.rol);

    final canCreateEvent = userProfile != null &&
        [
          AppConstants.rolePastor,
          AppConstants.roleAdmin,
          AppConstants.roleLider,
        ].contains(userProfile.rol);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Actividades del día\n${DateFormat('d \'de\' MMMM', 'es').format(date)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Lista de eventos
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventCard(context, ref, event, canManage);
                },
              ),
            ),
            // Botón para crear nuevo evento (si tiene permisos)
            if (canCreateEvent)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCreateEventModal(context, date);
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Nuevo Evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventModal(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => CreateEventModal(
        initialDate: date,
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
    bool canManage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorUtils.getLightColor(event.color, opacity: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento (si existe)
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                event.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          // Contenido del evento
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Hora
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('h:mm a', 'es')
                          .format(event.startTime.toDate()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ubicación
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                // Botón de recordatorio (para todos los usuarios)
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _createReminder(context, event),
                    icon: const Icon(Icons.notifications_active, size: 20),
                    label: const Text('Crear Recordatorio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Botones de acción (si puede gestionar)
                if (canManage) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showEditModal(context, event);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () =>
                            _showDeleteConfirmation(context, ref, event),
                        icon: const Icon(Icons.delete,
                            size: 18, color: Colors.red),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => CreateEventModal(
        initialDate: event.eventDate,
        eventToEdit: event,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    EventModel event,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el evento "${event.title}"?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Cerrar el modal de detalles
              try {
                await ref.read(eventServiceProvider).deleteEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evento eliminado con éxito')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _createReminder(BuildContext context, EventModel event) async {
    try {
      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange),
              SizedBox(width: 12),
              Text('Crear Recordatorio'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Se crearán 2 recordatorios para "${event.title}":'),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('El día del evento a las 8:00 AM'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('1 hora antes del evento'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
              ),
              child: const Text('Crear'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Importar el servicio dinámicamente para evitar errores si no está disponible
      try {
        final notificationService = LocalNotificationService();
        await notificationService.requestPermissions();
        await notificationService.scheduleEventReminders(event);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('✓ Recordatorios creados con éxito'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear recordatorios: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Error general
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear recordatorios'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Importación condicional del servicio de notificaciones
class LocalNotificationService {
  Future<void> requestPermissions() async {
    // Implementación básica - se puede extender
  }

  Future<void> scheduleEventReminders(EventModel event) async {
    // Mostrar mensaje amigable en lugar de error
    throw Exception(
      'Funcionalidad de recordatorios disponible próximamente. '
      'Requiere configuración de notificaciones locales.',
    );
  }
}
