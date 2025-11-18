// lib/screens/feed/create_post_screen.dart

import 'dart:io'; // Necesario para File
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// [CORRECCIÓN 1] Usamos el provider de servicios para inyectar UploadService
// Importamos el servicio de subida con alias para evitar problemas de resolución
// NOTE: Using inline upload logic here for the smoke test to avoid
// resolver/import issues with the external UploadService class.

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  XFile? _selectedImageFile;

  Future<void> _pickImage() async {
    try {
      final imagePicker = ImagePicker();
      // Bajamos la calidad a 70 para que suba más rápido en la prueba
      final pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    }
  }

  // [MODO SMOKE TEST]
  // Esta función reemplaza temporalmente la lógica de crear post
  // Su ÚNICO objetivo es probar si S3 funciona.
  Future<void> _testUploadOnly() async {
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Selecciona una imagen primero')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🚀 INICIANDO TEST DE SUBIDA A S3...");

      // 1. Convertir XFile (cross-platform) a File (dart:io)
      final fileToUpload = File(_selectedImageFile!.path);

      // 2. Llamar al endpoint para obtener URL firmada y subir directamente.
      // (Código tomado de `upload_service.dart` para evitar problemas de import.)
      const String apiUrl =
          'https://kw64z1i0pk.execute-api.us-east-1.amazonaws.com';
      try {
        final handshakeResp = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );

        if (handshakeResp.statusCode != 200) {
          throw Exception(
              'Error obteniendo URL firmada: ${handshakeResp.body}');
        }

        final data = jsonDecode(handshakeResp.body);
        final String uploadUrl = data['uploadURL'];
        final String objectKey = data['objectKey'];

        final uploadResp = await http.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': 'image/jpeg'},
          body: await fileToUpload.readAsBytes(),
        );

        if (uploadResp.statusCode == 200) {
          // éxito
          if (mounted) {
            print('🎉 ¡Subida exitosa! Key: $objectKey');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('🎉 ÉXITO: Imagen subida a S3! Key: $objectKey')),
            );
          }
        } else {
          throw Exception(
              'Error subiendo a S3: ${uploadResp.statusCode} - ${uploadResp.body}');
        }
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      print("❌ EXCEPCIÓN: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error crítico: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión AWS'), // Título temporal
        backgroundColor:
            Colors.amber, // Color de advertencia (estamos probando)
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_upload), // Icono de subida
              // [CORRECCIÓN 2] Llamamos a la función de prueba, no a la de post
              onPressed: _testUploadOnly,
              tooltip: "Probar subida a S3",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "MODO DE PRUEBA (SMOKE TEST)",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "1. Selecciona una foto.\n2. Pulsa el icono de la nube arriba a la derecha.\n3. Espera el mensaje verde.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Visualizador de imagen
              if (_selectedImageFile != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                        image: DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_selectedImageFile!.path)
                              : FileImage(File(_selectedImageFile!.path))
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedImageFile = null;
                        });
                      },
                    ),
                  ],
                )
              else
                Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: Text("Sin imagen")),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
