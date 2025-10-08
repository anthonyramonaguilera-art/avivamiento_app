// lib/screens/feed/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/providers/services_provider.dart';
import 'package:avivamiento_app/providers/user_data_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = ref.read(userProfileProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Debes estar autenticado para publicar.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final postService = ref.read(postServiceProvider);
        // [MODIFICADO] Ahora pasamos los datos desnormalizados del autor.
        await postService.createPost(
          content: _textController.text.trim(),
          authorId: user.id,
          authorName: user.nombre,
          authorPhotoUrl: user.fotoUrl, // <-- AÑADIDO
          authorRole: user.rol, // <-- AÑADIDO
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la publicación: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... El resto del archivo no cambia ...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Publicación'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitPost,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '¿Qué estás pensando?',
              border: InputBorder.none,
            ),
            maxLines: null,
            validator: (value) => value!.trim().isEmpty
                ? 'El contenido no puede estar vacío'
                : null,
          ),
        ),
      ),
    );
  }
}
