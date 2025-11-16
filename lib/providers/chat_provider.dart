// lib/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que expone la lista de mensajes del chat en tiempo real.
final chatMessagesProvider = StreamProvider<List<ChatMessageModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getChatMessagesStream();
});
