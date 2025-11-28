// lib/providers/services_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/services/bible_service.dart';
import 'package:avivamiento_app/services/auth_service.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/services/event_service.dart';
import 'package:avivamiento_app/services/chat_service.dart';
import 'package:avivamiento_app/services/notification_service.dart';
import 'package:avivamiento_app/services/livestream_service.dart';
import 'package:avivamiento_app/services/conference_service.dart';
import 'package:avivamiento_app/services/backend/event_backend.dart';
import 'package:avivamiento_app/services/backend/firestore_event_backend.dart';
// import 'package:avivamiento_app/services/backend/aws_event_backend.dart'; // Descomentar para AWS

// --- Instancias de Firebase (Singletons) ---
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// --- Backend Providers ---
// Cambiar entre Firestore y AWS aquí
final eventBackendProvider = Provider<EventBackend>((ref) {
  // Para usar Firestore:
  return FirestoreEventBackend(ref.watch(firestoreProvider));

  // Para usar AWS (descomentar cuando esté listo):
  // return AWSEventBackend(
  //   apiBaseUrl: 'https://tu-api-gateway-url.amazonaws.com/prod',
  // );
});

// --- Proveedores de Servicios ---
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firestoreProvider));
});

final postServiceProvider = Provider<PostService>((ref) {
  return PostService();
});

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService(ref.watch(eventBackendProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.watch(firestoreProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final livestreamServiceProvider = Provider<LivestreamService>((ref) {
  return LivestreamService(ref.watch(firestoreProvider));
});

final conferenceServiceProvider = Provider<ConferenceService>((ref) {
  return ConferenceService(ref.watch(firestoreProvider));
});

final bibleServiceProvider = Provider<BibleService>((ref) {
  return BibleService();
});
