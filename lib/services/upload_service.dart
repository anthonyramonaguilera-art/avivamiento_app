import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  // ⚠️ REEMPLAZA ESTO con tu URL real del API Gateway
  // No incluyas el endpoint específico si lo concatenas abajo, o pon la URL completa aquí.
  // Basado en tu curl:
  final String _apiUrl =
      'https://kw64z1i0pk.execute-api.us-east-1.amazonaws.com/generate-upload-url';

  /// Realiza el "baile de dos pasos" para subir una imagen a AWS S3.
  /// Retorna el [objectKey] (el nombre del archivo en S3) si es exitoso, o null si falla.
  Future<String?> uploadImageToS3(File imageFile) async {
    try {
      // --- PASO 1: El Handshake (Pedir permiso al "Notario") ---
      print('📡 Solicitando URL firmada a Lambda...');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {}), // Por ahora enviamos body vacío, más adelante podríamos enviar la extensión del archivo
      );

      if (response.statusCode != 200) {
        print('❌ Error al obtener URL firmada: ${response.body}');
        return null;
      }

      // Parseamos el "Payload"
      final data = jsonDecode(response.body);
      final String uploadUrl = data['uploadURL'];
      final String objectKey =
          data['objectKey']; // Guardaremos esto en la Base de Datos luego

      print('✅ URL Recibida. Key: $objectKey');

      // --- PASO 2: La Subida Directa (Direct Upload) ---
      // Aquí hablamos directamente con S3, sin pasar por Lambda.
      // ⚠️ IMPORTANTE: Usamos PUT, no POST. Y enviamos los bytes crudos.

      print('🚀 Subiendo archivo a S3...');
      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type':
              'image/jpeg', // Debe coincidir con lo que firmó la Lambda
        },
        body: await imageFile
            .readAsBytes(), // Leemos el archivo como bytes binarios
      );

      if (uploadResponse.statusCode == 200) {
        print('🎉 ¡Subida exitosa a S3!');
        return objectKey; // Retornamos la "llave" para guardarla en DynamoDB
      } else {
        print(
            '❌ Error al subir a S3: ${uploadResponse.statusCode} - ${uploadResponse.body}');
        return null;
      }
    } catch (e) {
      print('❌ Excepción en upload: $e');
      return null;
    }
  }

  /// Subir video a S3 con progreso
  /// Límite: 50MB (52428800 bytes)
  Future<String?> uploadVideoToS3(
    File videoFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Validar tamaño (50MB)
      final fileSize = await videoFile.length();
      const maxSize = 52428800; // 50MB en bytes

      if (fileSize > maxSize) {
        print(
            '❌ Video demasiado grande: ${fileSize / 1024 / 1024}MB (máximo: 50MB)');
        throw Exception('El video no puede superar 50MB');
      }

      print('📡 Solicitando URL firmada para video...');

      // Paso 1: Obtener URL firmada (similar a imagen pero con contentType diferente)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fileType': 'video',
          'contentType': 'video/mp4', // Asumimos MP4, ajustar según necesidad
        }),
      );

      if (response.statusCode != 200) {
        print('❌ Error al obtener URL firmada: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final String uploadUrl = data['uploadURL'];
      final String objectKey = data['objectKey'];

      print('✅ URL Recibida. Key: $objectKey');

      // Paso 2: Subir a S3
      print('🚀 Subiendo video a S3...');
      final videoBytes = await videoFile.readAsBytes();

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'video/mp4'},
        body: videoBytes,
      );

      if (onProgress != null) {
        onProgress(1.0); // Completado
      }

      if (uploadResponse.statusCode == 200) {
        print('🎉 ¡Video subido exitosamente a S3!');
        return objectKey;
      } else {
        print('❌ Error al subir video: ${uploadResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Excepción en uploadVideoToS3: $e');
      rethrow;
    }
  }

  /// Subir audio a S3 con progreso
  /// Límite: 10MB (10485760 bytes)
  Future<String?> uploadAudioToS3(
    File audioFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Validar tamaño (10MB)
      final fileSize = await audioFile.length();
      const maxSize = 10485760; // 10MB en bytes

      if (fileSize > maxSize) {
        print(
            '❌ Audio demasiado grande: ${fileSize / 1024 / 1024}MB (máximo: 10MB)');
        throw Exception('El audio no puede superar 10MB');
      }

      print('📡 Solicitando URL firmada para audio...');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fileType': 'audio',
          'contentType': 'audio/mpeg', // MP3 por defecto
        }),
      );

      if (response.statusCode != 200) {
        print('❌ Error al obtener URL firmada: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final String uploadUrl = data['uploadURL'];
      final String objectKey = data['objectKey'];

      print('✅ URL Recibida para audio. Key: $objectKey');

      // Paso 2: Subir a S3
      print('🚀 Subiendo audio a S3...');
      final audioBytes = await audioFile.readAsBytes();

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'audio/mpeg'},
        body: audioBytes,
      );

      if (onProgress != null) {
        onProgress(1.0);
      }

      if (uploadResponse.statusCode == 200) {
        print('🎉 ¡Audio subido exitosamente a S3!');
        return objectKey;
      } else {
        print('❌ Error al subir audio: ${uploadResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Excepción en uploadAudioToS3: $e');
      rethrow;
    }
  }
}
