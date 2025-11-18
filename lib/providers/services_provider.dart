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

// --- Instancias de Firebase (Singletons) ---
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
// [ELIMINADO] Ya no necesitamos un provider global para Storage si solo se usa en un lugar específico
// final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

// --- Proveedores de Servicios ---
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firestoreProvider));
});

// [CORRECCIÓN] Ahora el postServiceProvider solo necesita la dependencia de Firestore.
final postServiceProvider = Provider<PostService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PostService(firestore); // Se elimina el segundo argumento 'storage'
});

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService(ref.watch(firestoreProvider));
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

/// Provider para `UploadService` usado en la pantalla de pruebas y subida de imágenes.
// Nota: `UploadService` se usa directamente en pantallas de prueba. Si prefieres
// inyectarlo, podemos volver a añadir un provider aquí; lo eliminé temporalmente
// porque el analizador estaba reportando que `UploadService` no era visible.
