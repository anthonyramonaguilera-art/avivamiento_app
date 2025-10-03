import 'package:avivamiento_app/models/post_model.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/services/auth_service.dart';
import 'package:avivamiento_app/services/user_service.dart';
import 'package:avivamiento_app/services/post_service.dart';
import 'package:avivamiento_app/services/event_service.dart';
import 'package:avivamiento_app/services/chat_service.dart';
// --- Proveedores de Streams de Datos ---
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
// lib/providers/services_provider.dart


// --- Instancias de Firebase (Singletons) ---
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// --- Proveedores de Servicios ---
// Este archivo ahora solo se encarga de crear las instancias de nuestros servicios.

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
