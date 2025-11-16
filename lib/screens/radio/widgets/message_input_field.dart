// lib/screens/radio/widgets/message_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';

class MessageInputField extends ConsumerStatefulWidget {
  const MessageInputField({super.key});

  @override
  ConsumerState<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends ConsumerState<MessageInputField> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      // [MODIFICADO] Pasamos los nuevos datos del autor al servicio.
      ref
          .read(chatServiceProvider)
          .sendMessage(
            text: text,
            authorId: user.id,
            authorName: user.nombre,
            authorPhotoUrl: user.fotoUrl, // <-- AÑADIDO
            authorRole: user.rol, // <-- AÑADIDO
          );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... El resto del archivo no cambia ...
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
