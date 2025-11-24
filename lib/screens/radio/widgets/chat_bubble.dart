// lib/screens/radio/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:avivamiento_app/models/chat_message_model.dart';
import 'package:avivamiento_app/utils/app_helpers.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // [NUEVO] Lógica para saber si el autor tiene foto
    final bool hasPhoto =
        message.authorPhotoUrl != null && message.authorPhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // [NUEVO] Muestra el avatar solo si el mensaje no es mío
          if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundImage: hasPhoto
                  ? NetworkImage(message.authorPhotoUrl!)
                  : null,
              child: !hasPhoto ? const Icon(Icons.person, size: 15) : null,
            ),
          const SizedBox(width: 8),

          // --- CONTENEDOR DEL MENSAJE ---
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe 
                    ? Theme.of(context).colorScheme.primaryContainer 
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe) // Muestra nombre y rol solo si no es mío
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${message.authorName} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '(${message.authorRole})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: getRoleColor(message.authorRole),
                          ),
                        ),
                      ],
                    ),

                  // --- TEXTO DEL MENSAJE ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(message.text),
                  ),

                  // --- HORA DEL MENSAJE ---
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp.toDate()),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          // [NUEVO] Añade un espacio en blanco si el mensaje es mío para alinear
          if (isMe)
            const SizedBox(width: 46), // Avatar (30) + SizedBox (8) * 2 = 46
        ],
      ),
    );
  }
}
