// lib/screens/calendar/widgets/calendar_grid_widget.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/screens/calendar/widgets/calendar_day_cell.dart';

/// Widget para la cuadrícula del calendario mensual.
class CalendarGridWidget extends StatelessWidget {
  final DateTime displayMonth;
  final List<EventModel> events;
  final Function(DateTime day, List<EventModel> dayEvents) onDayTap;

  const CalendarGridWidget({
    super.key,
    required this.displayMonth,
    required this.events,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final firstWeekday =
        firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    final today = DateTime.now();
    final isCurrentMonth =
        displayMonth.year == today.year && displayMonth.month == today.month;

    return Column(
      children: [
        // Header con días de la semana
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        // Grid de días
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              // Días vacíos antes del primer día del mes
              return const SizedBox.shrink();
            }

            final day = index - firstWeekday + 1;
            final date = DateTime(displayMonth.year, displayMonth.month, day);
            final dayEvents = _getEventsForDay(date);
            final isToday = isCurrentMonth && day == today.day;

            return CalendarDayCell(
              day: day,
              isCurrentMonth: true,
              isToday: isToday,
              events: dayEvents,
              onTap: () => onDayTap(date, dayEvents),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    return events.where((event) {
      final eventDate = event.eventDate;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }
}
