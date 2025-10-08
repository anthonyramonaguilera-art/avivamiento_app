// lib/screens/radio/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

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
            // [MODIFICADO] Mostramos el nombre y el rol juntos.
            Text(
              '${message.authorName} (${message.authorRole})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
