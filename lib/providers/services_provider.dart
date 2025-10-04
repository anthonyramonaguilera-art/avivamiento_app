// lib/providers/services_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/services/livestream_service.dart';
import 'package:avivamiento_app/services/auth_service.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/services/event_service.dart';
import 'package:avivamiento_app/services/chat_service.dart';
import 'package:avivamiento_app/services/notification_service.dart'; // [NUEVO]

// --- Instancias de Firebase (Singletons) ---
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// --- Proveedores de Servicios ---
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firestoreProvider));
});

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(ref.watch(firestoreProvider));
});

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService(ref.watch(firestoreProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.watch(firestoreProvider));
});

// [NUEVO] Proveedor para nuestro servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final livestreamServiceProvider = Provider<LivestreamService>((ref) {
  return LivestreamService(ref.watch(firestoreProvider));
});
