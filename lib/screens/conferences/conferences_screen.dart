// lib/screens/conferences/conferences_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:avivamiento_app/models/conference_room_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';

// 1. Creamos el StreamProvider que nos dará la lista de salas de conferencia
final conferenceRoomsProvider = StreamProvider<List<ConferenceRoomModel>>((
  ref,
) {
  final conferenceService = ref.watch(conferenceServiceProvider);
  return conferenceService.getConferenceRoomsStream();
});

class ConferencesScreen extends ConsumerWidget {
  const ConferencesScreen({super.key});

  // 2. Lógica para unirse a una conferencia
  void _joinConference(
    BuildContext context,
    WidgetRef ref,
    ConferenceRoomModel room,
  ) {
    final user = ref.read(userProfileProvider).value;

    // Verificación de seguridad básica
    if (user == null || user.rol == 'Invitado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para unirte a una conferencia.'),
        ),
      );
      return;
    }

    // Lógica de permisos para salas privadas
    if (room.accessType == 'privada' && !room.allowedRoles.contains(user.rol)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permiso para unirte a esta sala.'),
        ),
      );
      return;
    }

    // Configuración de la reunión de Jitsi
    final jitsiMeet = JitsiMeet();
    var options = JitsiMeetConferenceOptions(
      room: room.jitsiRoomName,
  serverURL:
          "https://meet.jit.si", // Usamos el servidor público y gratuito de Jitsi
      userInfo: JitsiMeetUserInfo(
        displayName: user.nombre,
        email: user.email,
        avatar: user.fotoUrl,
      ),
      featureFlags: {
        "chat.enabled": true,
        "invite.enabled":
            false, // Deshabilitamos la invitación para controlar el acceso
        "raise-hand.enabled": true,
        "live-streaming.enabled":
            false, // Deshabilitamos transmisión para mantenerlo simple
      },
    );

    jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsyncValue = ref.watch(conferenceRoomsProvider);
    final currentUser = ref.watch(userProfileProvider).value;

    return Scaffold(
      body: roomsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar las salas: $error')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Text('No hay conferencias programadas.'),
            );
          }

          // Filtramos la lista para mostrar solo las salas a las que el usuario puede unirse
          final accessibleRooms = rooms.where((room) {
            if (currentUser == null || currentUser.rol == 'Invitado')
              return false;
            if (room.accessType == 'publica') return true;
            return room.allowedRoles.contains(currentUser.rol);
          }).toList();

          if (accessibleRooms.isEmpty) {
            return const Center(
              child: Text('No hay conferencias disponibles para tu rol.'),
            );
          }

          return ListView.builder(
            itemCount: accessibleRooms.length,
            itemBuilder: (context, index) {
              final room = accessibleRooms[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.video_call, color: Colors.green),
                  title: Text(room.topic),
                  subtitle: Text(
                    'Programada para: ${room.scheduledDate.toDate().toLocal()}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _joinConference(context, ref, room),
                    child: const Text('Unirse'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
