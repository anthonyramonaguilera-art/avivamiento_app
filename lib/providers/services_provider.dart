// lib/providers/services_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart'
    as http; // Asegúrate de que este import esté si no lo tienes

// Models (asumiendo que los tienes en la carpeta models)
import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';

// Services
import 'package:avivamiento_app/services/auth_service.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/services/event_service.dart';
import 'package:avivamiento_app/services/chat_service.dart';

// --- Instancias de Firebase ---
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

// --- [NUEVO] Proveedor de Estado de Autenticación ---
/// Un StreamProvider que escucha los cambios de estado de autenticación de Firebase.
/// La aplicación reaccionará a este provider para mostrar la pantalla de Home o la de Login.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// --- Proveedores de Datos (Streams) ---
final postsProvider = StreamProvider<List<PostModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream();
});

final eventsProvider = StreamProvider<List<EventModel>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getEventsStream();
});

final chatMessagesProvider = StreamProvider<List<ChatMessageModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatMessagesStream();
});
