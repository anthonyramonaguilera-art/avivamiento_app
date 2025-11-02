import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;

  Future<DateTime?> _pickDateTime(
    BuildContext context, {
    required DateTime initialDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submitEvent(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, seleccione las fechas de inicio y fin'),
          ),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final eventService = ref.read(eventServiceProvider);
        await eventService.createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          startTime: Timestamp.fromDate(_startTime!),
          endTime: Timestamp.fromDate(_endTime!),
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear el evento: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Evento'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              : Consumer(
                  builder: (context, ref, _) => IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _submitEvent(context, ref),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del Evento',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El título es requerido' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha y Hora de Inicio'),
                subtitle: Text(_startTime?.toString() ?? 'No seleccionada'),
                onTap: () async {
                  final pickedTime = await _pickDateTime(
                    context,
                    initialDate: _startTime ?? DateTime.now(),
                  );
                  if (pickedTime != null)
                    setState(() => _startTime = pickedTime);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha y Hora de Fin'),
                subtitle: Text(_endTime?.toString() ?? 'No seleccionada'),
                onTap: () async {
                  final pickedTime = await _pickDateTime(
                    context,
                    initialDate: _endTime ?? _startTime ?? DateTime.now(),
                  );
                  if (pickedTime != null) setState(() => _endTime = pickedTime);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
