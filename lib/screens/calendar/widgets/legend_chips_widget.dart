// lib/screens/calendar/widgets/legend_chips_widget.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';

/// Widget que muestra las leyendas de eventos en un grid compacto.
class LegendChipsWidget extends StatelessWidget {
  final List<EventLegend> legends;

  const LegendChipsWidget({
    super.key,
    required this.legends,
  });

  @override
  Widget build(BuildContext context) {
    if (legends.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: legends.map((legend) {
          return _buildLegendChip(legend);
        }).toList(),
      ),
    );
  }

  Widget _buildLegendChip(EventLegend legend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            legend.color.withOpacity(0.15),
            legend.color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: legend.color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: legend.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: legend.color.withOpacity(0.4),
                  blurRadius: 3,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            legend.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
