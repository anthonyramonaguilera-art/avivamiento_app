// lib/screens/calendar/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/providers/events_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/providers/editable_legends_provider.dart';
import 'package:avivamiento_app/utils/constants.dart';
import 'package:avivamiento_app/screens/calendar/widgets/calendar_grid_widget.dart';
import 'package:avivamiento_app/screens/calendar/widgets/legend_chips_widget.dart';
import 'package:avivamiento_app/screens/calendar/modals/event_details_modal.dart';
import 'package:avivamiento_app/screens/calendar/modals/create_event_modal.dart';

/// Pantalla principal del calendario con vista mensual.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime.now();
    // Inicializar leyendas predeterminadas si no existen
    Future.microtask(() => ref.read(initializeLegendsProvider));
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + delta,
        1,
      );
    });
  }

  void _onDayTap(DateTime day, List<EventModel> dayEvents) {
    final userProfile = ref.read(userProfileProvider).value;

    if (dayEvents.isEmpty) {
      // Si no hay eventos y el usuario puede crear eventos
      if (userProfile != null &&
          [
            AppConstants.rolePastor,
            AppConstants.roleAdmin,
            AppConstants.roleLider,
          ].contains(userProfile.rol)) {
        _showCreateEventModal(day);
      }
    } else {
      // Siempre mostrar detalles si hay eventos (permite crear más eventos)
      _showEventDetailsModal(day, dayEvents);
    }
  }

  void _showEventDetailsModal(DateTime day, List<EventModel> events) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsModal(
        date: day,
        events: events,
      ),
    );
  }

  void _showCreateEventModal(DateTime day) {
    showDialog(
      context: context,
      builder: (context) => CreateEventModal(
        initialDate: day,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsyncValue = ref.watch(eventsProvider);
    final legendsAsyncValue = ref.watch(editableLegendsProvider);
    final userProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Calendario de actividades en',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Centro Internacional\nAvivamiento Venezuela',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Navegación de mes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'es').format(_displayMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Leyendas locales
            legendsAsyncValue.when(
              data: (legends) => LegendChipsWidget(legends: legends),
              loading: () => const SizedBox(height: 50),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Calendario
            Expanded(
              child: eventsAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
                data: (allEvents) {
                  // Filtrar eventos por rol del usuario
                  final visibleEvents = userProfile != null
                      ? allEvents
                          .where((event) =>
                              event.isVisibleForRole(userProfile.rol))
                          .toList()
                      : allEvents
                          .where((event) => event.targetRoles.contains('Todos'))
                          .toList();

                  // Filtrar eventos del mes actual
                  final monthEvents = visibleEvents.where((event) {
                    final eventDate = event.eventDate;
                    return eventDate.year == _displayMonth.year &&
                        eventDate.month == _displayMonth.month;
                  }).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: CalendarGridWidget(
                      displayMonth: _displayMonth,
                      events: monthEvents,
                      onDayTap: _onDayTap,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB removido - ahora solo se crea evento pulsando el día
    );
  }
}
