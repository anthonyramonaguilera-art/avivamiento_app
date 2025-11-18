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
}
