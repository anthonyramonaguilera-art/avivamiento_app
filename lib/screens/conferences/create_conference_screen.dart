// lib/screens/conferences/create_conference_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/utils/constants.dart'; // [NUEVO] Necesitamos nuestras constantes de roles

class CreateConferenceScreen extends ConsumerStatefulWidget {
  const CreateConferenceScreen({super.key});

  @override
  ConsumerState<CreateConferenceScreen> createState() => _CreateConferenceScreenState();
}

class _CreateConferenceScreenState extends ConsumerState<CreateConferenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _roomNameController = TextEditingController();
  String _accessType = 'publica';
  bool _isLoading = false;

  // [NUEVO] Lista para guardar los roles que el admin seleccione para la sala privada.
  final List<String> _selectedRoles = [];

  @override
  void dispose() {
    _topicController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // [NUEVO] Validación adicional: si la sala es privada, al menos un rol debe ser seleccionado.
      if (_accessType == 'privada' && _selectedRoles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Para una sala privada, debes seleccionar al menos un rol permitido.')),
        );
        return; // Detenemos el envío del formulario.
      }

      setState(() => _isLoading = true);

      try {
        final conferenceService = ref.read(conferenceServiceProvider);
        await conferenceService.createConferenceRoom(
          topic: _topicController.text.trim(),
          jitsiRoomName: _roomNameController.text.trim(),
          accessType: _accessType,
          // [CAMBIO] Pasamos la lista de roles seleccionados.
          allowedRoles: _selectedRoles,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sala de conferencia creada con éxito')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la sala: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Reunión'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
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
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Tema de la Reunión'),
                validator: (value) => value!.trim().isEmpty ? 'El tema es requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Sala (para Jitsi)',
                  hintText: 'Ej: ReunionLideres2025',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'El nombre de la sala es requerido';
                  if (value.contains(' ')) return 'El nombre no puede contener espacios';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _accessType,
                decoration: const InputDecoration(labelText: 'Tipo de Acceso'),
                items: const [
                  DropdownMenuItem(value: 'publica', child: Text('Pública - Abierta a todos')),
                  DropdownMenuItem(value: 'privada', child: Text('Privada - Solo por roles')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _accessType = value;
                    });
                  }
                },
              ),

              // [NUEVO] Widget condicional para la selección de roles
              // Solo aparece si el tipo de acceso es 'privada'
              if (_accessType == 'privada') ...[
                const SizedBox(height: 24),
                Text('¿Quiénes pueden entrar?', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                // Usamos un Wrap para que los checkboxes se acomoden si no caben en una línea.
                Wrap(
                  spacing: 8.0,
                  children: AppConstants.allRoles.map((role) {
                    // No tiene sentido invitar al rol 'Invitado' a una sala privada.
                    if (role == AppConstants.roleInvitado) {
                      return const SizedBox.shrink(); // Un widget vacío
                    }

                    return FilterChip(
                      label: Text(role),
                      selected: _selectedRoles.contains(role),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}