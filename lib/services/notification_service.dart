// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // 1. Solicitar permisos al usuario
    await _requestPermissions();

    // 2. Obtener el token del dispositivo
    final fcmToken = await _getToken();
    print('============================================');
    print('FCM Token: $fcmToken');
    print('============================================');

    // 3. Configurar listeners para manejar los mensajes
    _handleIncomingMessages();
  }

  /// Solicita los permisos necesarios para mostrar notificaciones.
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido.');
    } else {
      print('El usuario ha denegado los permisos de notificación.');
    }
  }

  /// Obtiene el token de registro único para este dispositivo.
  /// Este token se usa para enviar notificaciones a un dispositivo específico.
  Future<String?> _getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Configura los manejadores para los diferentes estados en los que se puede recibir un mensaje.
  void _handleIncomingMessages() {
    // Mensaje recibido mientras la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('¡Notificación recibida en primer plano!');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');

      // Aquí podrías mostrar un diálogo o una notificación local
    });

    // Manejador para cuando el usuario toca la notificación y la app estaba en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('La app se abrió desde una notificación en segundo plano.');
      // Aquí podrías navegar a una pantalla específica, por ejemplo:
      // navigatorKey.currentState?.pushNamed('/ruta_especifica');
    });

    // Manejador para cuando el usuario toca la notificación y la app estaba terminada
    // Se ejecuta una vez al inicio.
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('La app se abrió desde una notificación con la app terminada.');
        // Lógica similar a onMessageOpenedApp
      }
    });
  }
}
