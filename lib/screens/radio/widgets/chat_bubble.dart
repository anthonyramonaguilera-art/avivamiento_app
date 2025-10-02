// lib/screens/radio/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';

/// Una "burbuja" que representa un único mensaje en el chat.
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe; // Para alinear el mensaje a la derecha si es mío

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.authorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
