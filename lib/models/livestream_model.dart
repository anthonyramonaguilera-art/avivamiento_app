// lib/models/livestream_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para una transmisión en vivo o pasada.
/// Cada instancia corresponde a un documento en la colección 'livestreams' de Firestore.
class LivestreamModel {
  /// El ID único del documento.
  final String id;

  /// El título del video (ej: "Servicio Dominical - La Fe que Mueve Montañas").
  final String title;

  /// La URL del video (ej: un enlace de YouTube o Facebook).
  final String videoUrl;

  /// La URL de la imagen miniatura del video.
  final String thumbnailUrl;

  /// La fecha en que se realizó la transmisión.
  final Timestamp broadcastDate;

  /// Un indicador para saber si la transmisión está actualmente en vivo.
  final bool isLive;

  LivestreamModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.broadcastDate,
    this.isLive = false,
  });

  /// Factory constructor para crear una instancia desde un mapa de datos de Firestore.
  factory LivestreamModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return LivestreamModel(
      id: documentId,
      title: data['title'] ?? 'Sin Título',
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl:
          data['thumbnailUrl'] ??
          '', // Usaremos un placeholder si no hay imagen
      broadcastDate: data['broadcastDate'] ?? Timestamp.now(),
      isLive: data['isLive'] ?? false,
    );
  }
}
