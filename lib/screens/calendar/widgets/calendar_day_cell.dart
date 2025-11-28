// lib/screens/calendar/widgets/calendar_day_cell.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/utils/color_utils.dart';

/// Widget para cada celda de día en el calendario.
class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool isToday;
  final List<EventModel> events;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEvents = events.isNotEmpty;
    final eventColors = events.map((e) => e.color).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // Fondo con colores de eventos
            if (hasEvents)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: eventColors.length == 1
                      ? null
                      : ColorUtils.createEventGradient(eventColors),
                  color: eventColors.length == 1 ? eventColors[0] : null,
                ),
              ),
            // Número del día
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: hasEvents
                      ? Colors.white
                      : isCurrentMonth
                          ? Colors.black87
                          : Colors.grey.shade400,
                ),
              ),
            ),
            // Indicador de múltiples eventos
            if (events.length > 1)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
