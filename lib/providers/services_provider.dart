import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/services/event_service.dart';
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/models/event_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart'; // Nuevo: Importa UserService

// 1. Provider para la instancia de FirebaseAuth.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// Nuevo: Provider para la instancia de FirebaseFirestore.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// 2. Provider para nuestro AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

// Nuevo: Provider para nuestro UserService.
// Este provider crea una instancia de UserService, pasándole la instancia de FirebaseFirestore.
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firebaseFirestoreProvider));
});

// 3. StreamProvider para el estado de autenticación.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Puedes añadir más providers aquí en el futuro.

/// Proveedor para el servicio de gestión de publicaciones.

/// Proveedor para el servicio de gestión de publicaciones.
final postServiceProvider = Provider<PostService>((ref) {
  return PostService(ref.watch(firebaseFirestoreProvider));
});

/// [NUEVO] Proveedor para el servicio de gestión de eventos.

/// Proveedor para el servicio de gestión de eventos.
final eventServiceProvider = Provider<EventService>((ref) {
  return EventService(ref.watch(firebaseFirestoreProvider));
});

/// Un StreamProvider que expone la lista de publicaciones.

/// Un StreamProvider que expone la lista de publicaciones.
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream();
});

/// [NUEVO] Un StreamProvider que expone la lista de eventos en tiempo real.
final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getEventsStream();
});
