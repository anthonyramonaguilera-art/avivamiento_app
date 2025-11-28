// lib/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:avivamiento_app/models/event_model.dart';

/// Servicio para gestionar notificaciones locales de recordatorios de eventos.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el servicio de notificaciones locales.
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Solicita permisos para notificaciones (iOS principalmente).
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Crea recordatorios para un evento (día del evento y 1 hora antes).
  Future<void> scheduleEventReminders(EventModel event) async {
    await initialize();

    final eventTime = event.startTime.toDate();
    final now = DateTime.now();

    // ID único basado en el ID del evento
    final eventDayId = event.id.hashCode;
    final oneHourBeforeId = event.id.hashCode + 1;

    // Notificación el día del evento (a las 8 AM)
    final eventDayTime = DateTime(
      eventTime.year,
      eventTime.month,
      eventTime.day,
      8,
      0,
    );

    if (eventDayTime.isAfter(now)) {
      await _scheduleNotification(
        id: eventDayId,
        title: '📅 Evento Hoy: ${event.title}',
        body: 'Hoy tienes "${event.title}" a las ${_formatTime(eventTime)}',
        scheduledTime: eventDayTime,
      );
    }

    // Notificación 1 hora antes del evento
    final oneHourBefore = eventTime.subtract(const Duration(hours: 1));

    if (oneHourBefore.isAfter(now)) {
      await _scheduleNotification(
        id: oneHourBeforeId,
        title: '⏰ Recordatorio: ${event.title}',
        body: 'El evento comienza en 1 hora en ${event.location}',
        scheduledTime: oneHourBefore,
      );
    }
  }

  /// Programa una notificación individual.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Recordatorios de Eventos',
      channelDescription: 'Notificaciones para recordatorios de eventos',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela todos los recordatorios de un evento.
  Future<void> cancelEventReminders(String eventId) async {
    final eventDayId = eventId.hashCode;
    final oneHourBeforeId = eventId.hashCode + 1;

    await _notifications.cancel(eventDayId);
    await _notifications.cancel(oneHourBeforeId);
  }

  /// Formatea la hora en formato legible.
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Obtiene todas las notificaciones pendientes.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
