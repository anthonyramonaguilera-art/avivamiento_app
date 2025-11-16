// lib/screens/conferences/conferences_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:avivamiento_app/models/conference_room_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';
import 'package:avivamiento_app/screens/conferences/create_conference_screen.dart';
import 'package:avivamiento_app/utils/constants.dart';

final conferenceRoomsProvider = StreamProvider<List<ConferenceRoomModel>>((ref) {
  final conferenceService = ref.watch(conferenceServiceProvider);
  return conferenceService.getConferenceRoomsStream();
});

class ConferencesScreen extends ConsumerWidget {
  const ConferencesScreen({super.key});

  void _joinConference(BuildContext context, WidgetRef ref, ConferenceRoomModel room) {
    final userProfile = ref.read(userProfileProvider).value;

    // [NUEVO] Lógica de validación de acceso
    final bool isPublic = room.accessType == 'publica';
    final bool hasPermission = userProfile != null && (room.allowedRoles.contains(userProfile.rol) || [AppConstants.rolePastor, AppConstants.roleAdmin].contains(userProfile.rol));

    // Si la sala no es pública y el usuario no tiene permiso, mostramos un mensaje y no hacemos nada más.
    if (!isPublic && !hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes permiso para unirte a esta sala privada.')),
      );
      return;
    }

    // Si tiene permiso, procede a unirse como antes.
    if (kIsWeb) {
      final url = 'https://meet.jit.si/${room.jitsiRoomName}';
      _launchURL(url);
    } else {
      final jitsiMeet = JitsiMeet();
      final options = JitsiMeetConferenceOptions(
        room: room.jitsiRoomName,
        userInfo: JitsiMeetUserInfo(
          displayName: userProfile?.nombre,
          email: userProfile?.email,
          avatar: userProfile?.fotoUrl,
        ),
        configOverrides: {"startWithAudioMuted": true, "startWithVideoMuted": true},
      );
      jitsiMeet.join(options);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('No se pudo lanzar la URL: $urlString');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsyncValue = ref.watch(conferenceRoomsProvider);
    final currentUser = ref.watch(userProfileProvider).value;
    final bool canCreate = currentUser != null &&
        [AppConstants.rolePastor, AppConstants.roleAdmin].contains(currentUser.rol);

    return Scaffold(
      body: roomsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error al cargar las salas: $error')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No hay reuniones programadas.'));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];

              // [NUEVO] Determinamos el estado visual de la tarjeta
              final bool isPublic = room.accessType == 'publica';
              // Un usuario tiene permiso si la sala es pública, o si su rol está en la lista de permitidos, o si es Pastor/Admin (ellos entran a todo).
              final bool hasPermission = currentUser != null && (isPublic || room.allowedRoles.contains(currentUser.rol) || [AppConstants.rolePastor, AppConstants.roleAdmin].contains(currentUser.rol));

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                // [NUEVO] Cambiamos el color si el usuario no tiene acceso, para dar feedback visual.
                color: hasPermission ? null : Colors.grey[300],
                child: ListTile(
                  // [NUEVO] El ícono cambia para mostrar si la sala es pública o privada.
                  leading: Icon(
                    isPublic ? Icons.lock_open : Icons.lock, 
                    color: isPublic ? Colors.green : Colors.red,
                  ),
                  title: Text(room.topic),
                  subtitle: Text(isPublic ? 'Sala Pública' : 'Sala Privada'),
                  trailing: hasPermission ? const Icon(Icons.arrow_forward_ios) : null,
                  onTap: () => _joinConference(context, ref, room),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateConferenceScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}