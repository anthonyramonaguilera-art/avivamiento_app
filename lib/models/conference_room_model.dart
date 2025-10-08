// lib/models/conference_room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para una sala de conferencias o reunión.
/// Cada instancia corresponde a un documento en la colección 'conferenceRooms' de Firestore.
class ConferenceRoomModel {
  /// El ID único del documento.
  final String id;

  /// El tema o título de la reunión (ej: "Reunión de Líderes Semanal").
  final String topic;

  /// El nombre único de la sala en Jitsi. Será algo como "AvivamientoReunionLideres01".
  final String jitsiRoomName;

  /// La fecha programada para la conferencia.
  final Timestamp scheduledDate;

  /// Define quién puede acceder. Puede ser 'publica' (todos los miembros) o 'privada' (roles específicos).
  final String accessType;

  /// Una lista de los roles que tienen permitido unirse si el acceso es 'privado'.
  /// (ej: ['Pastor', 'Líder', 'Adorador'])
  final List<String> allowedRoles;

  ConferenceRoomModel({
    required this.id,
    required this.topic,
    required this.jitsiRoomName,
    required this.scheduledDate,
    required this.accessType,
    this.allowedRoles = const [],
  });

  /// Factory constructor para crear una instancia desde un mapa de datos de Firestore.
  factory ConferenceRoomModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    // Convertimos la lista de roles que viene de Firestore.
    final List<dynamic> rolesFromDb = data['allowedRoles'] ?? [];
    final List<String> roles = rolesFromDb
        .map((role) => role.toString())
        .toList();

    return ConferenceRoomModel(
      id: documentId,
      topic: data['topic'] ?? 'Sala sin Título',
      jitsiRoomName: data['jitsiRoomName'] ?? '',
      scheduledDate: data['scheduledDate'] ?? Timestamp.now(),
      accessType: data['accessType'] ?? 'privada',
      allowedRoles: roles,
    );
  }
}
