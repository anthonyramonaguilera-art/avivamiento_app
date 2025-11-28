// lib/screens/calendar/modals/create_event_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/models/event_legend_model.dart';
import 'package:avivamiento_app/providers/editable_legends_provider.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/utils/constants.dart';

/// Modal para crear o editar un evento.
class CreateEventModal extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final EventModel? eventToEdit;

  const CreateEventModal({
    super.key,
    required this.initialDate,
    this.eventToEdit,
  });

  @override
  ConsumerState<CreateEventModal> createState() => _CreateEventModalState();
}

class _CreateEventModalState extends ConsumerState<CreateEventModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _selectedLegendName;
  Color? _selectedLegendColor;
  List<String> _selectedRoles = ['Todos'];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.eventToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.eventToEdit?.description ?? '');
    _locationController =
        TextEditingController(text: widget.eventToEdit?.location ?? '');
    _imageUrlController =
        TextEditingController(text: widget.eventToEdit?.imageUrl ?? '');

    if (widget.eventToEdit != null) {
      _startDateTime = widget.eventToEdit!.startTime.toDate();
      _endDateTime = widget.eventToEdit!.endTime.toDate();
      _selectedLegendName = widget.eventToEdit!.legendName;
      _selectedLegendColor = widget.eventToEdit!.color;
      _selectedRoles = List.from(widget.eventToEdit!.targetRoles);
    } else {
      _startDateTime = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        9,
        0,
      );
      _endDateTime = _startDateTime!.add(const Duration(hours: 2));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDateTime! : _endDateTime!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(isStart ? _startDateTime! : _endDateTime!),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDateTime = newDateTime;
          } else {
            _endDateTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLegendName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final eventService = ref.read(eventServiceProvider);

      final colorHex =
          '#${_selectedLegendColor!.value.toRadixString(16).substring(2).toUpperCase()}';

      final event = EventModel(
        id: widget.eventToEdit?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        startTime: Timestamp.fromDate(_startDateTime!),
        endTime: Timestamp.fromDate(_endDateTime!),
        legendName: _selectedLegendName!,
        legendColor: colorHex,
        targetRoles: _selectedRoles,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );

      if (widget.eventToEdit != null) {
        await eventService.updateEvent(event.id, event.toMap());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Evento actualizado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await eventService.createEvent(
          title: event.title,
          description: event.description,
          location: event.location,
          startTime: event.startTime,
          endTime: event.endTime,
          legendName: event.legendName,
          legendColor: event.legendColor,
          targetRoles: event.targetRoles,
          imageUrl: event.imageUrl,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Evento creado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final legendsAsync = ref.watch(editableLegendsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.eventToEdit != null
                        ? Icons.edit_calendar
                        : Icons.add_circle,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.eventToEdit != null
                          ? 'Editar Evento'
                          : 'Crear Nuevo Evento',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: legendsAsync.when(
                  data: (legends) => Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _titleController,
                          label: 'Título',
                          hint: 'Ej: Servicio Dominical',
                          icon: Icons.title,
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Detalles del evento...',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _locationController,
                          label: 'Ubicación',
                          hint: 'Ej: Santuario Principal',
                          icon: Icons.location_on,
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _imageUrlController,
                          label: 'URL de Imagen (opcional)',
                          hint: 'https://...',
                          icon: Icons.image,
                        ),
                        const SizedBox(height: 20),
                        _buildLegendSelector(legends),
                        const SizedBox(height: 20),
                        _buildRoleSelector(),
                        const SizedBox(height: 20),
                        _buildDateTimeSelector(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: required
              ? (value) => value?.trim().isEmpty ?? true
                  ? 'Este campo es requerido'
                  : null
              : null,
        ),
      ],
    );
  }

  Widget _buildLegendSelector(List<EventLegend> legends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Categoría',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: legends.map((legend) {
            final isSelected = _selectedLegendName == legend.name;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedLegendName = legend.name;
                  _selectedLegendColor = legend.color;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? legend.color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: legend.color,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: legend.color.withOpacity(0.3),
                              blurRadius: 8)
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : legend.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      legend.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 16),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              '¿Para quién es este evento?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Todos',
            AppConstants.rolePastor,
            AppConstants.roleAdmin,
            AppConstants.roleLider,
            AppConstants.roleMusico,
            AppConstants.roleMiembro
          ].map((role) {
            final isSelected = _selectedRoles.contains(role);
            final isTodos = role == 'Todos';

            return FilterChip(
              label: Text(role),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (isTodos) {
                    _selectedRoles = selected ? ['Todos'] : [];
                  } else {
                    if (selected) {
                      _selectedRoles.remove('Todos');
                      _selectedRoles.add(role);
                    } else {
                      _selectedRoles.remove(role);
                      if (_selectedRoles.isEmpty) {
                        _selectedRoles = ['Todos'];
                      }
                    }
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Fecha y Hora',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDateTimeCard(
          icon: Icons.event_available,
          title: 'Inicio',
          dateTime: _startDateTime!,
          onTap: () => _selectDateTime(context, true),
        ),
        const SizedBox(height: 12),
        _buildDateTimeCard(
          icon: Icons.event_busy,
          title: 'Fin',
          dateTime: _endDateTime!,
          onTap: () => _selectDateTime(context, false),
        ),
      ],
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String title,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEEE, d \'de\' MMMM \'a las\' h:mm a', 'es')
                        .format(dateTime),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.eventToEdit != null ? Icons.save : Icons.add_circle,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.eventToEdit != null ? 'Guardar Cambios' : 'Crear Evento',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
