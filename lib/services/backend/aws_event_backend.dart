// lib/services/backend/aws_event_backend.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avivamiento_app/models/event_model.dart';
import 'package:avivamiento_app/services/backend/event_backend.dart';

/// Implementación de EventBackend usando AWS (API Gateway + Lambda + DynamoDB).
class AWSEventBackend implements EventBackend {
  final String apiBaseUrl;
  final http.Client _client;

  AWSEventBackend({
    required this.apiBaseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Stream<List<EventModel>> getEventsStream() async* {
    // Para AWS, implementamos polling cada 30 segundos
    while (true) {
      try {
        final response = await _client.get(
          Uri.parse('$apiBaseUrl/events'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          yield data
              .map((item) => EventModel.fromMap(item, item['id']))
              .toList();
        } else {
          yield [];
        }
      } catch (e) {
        yield [];
      }

      await Future.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Future<List<EventModel>> getEventsForMonth(int year, int month) async {
    try {
      final response = await _client.get(
        Uri.parse('$apiBaseUrl/events?year=$year&month=$month'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => EventModel.fromMap(item, item['id']))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EventModel>> getEventsForDay(DateTime day) async {
    try {
      final dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final response = await _client.get(
        Uri.parse('$apiBaseUrl/events?date=$dateStr'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => EventModel.fromMap(item, item['id']))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    // Convertir Timestamp a ISO string para AWS
    final data = _prepareDataForAWS(eventData);

    final response = await _client.post(
      Uri.parse('$apiBaseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    final preparedData = _prepareDataForAWS(data);

    final response = await _client.put(
      Uri.parse('$apiBaseUrl/events/$eventId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(preparedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event: ${response.body}');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final response = await _client.delete(
      Uri.parse('$apiBaseUrl/events/$eventId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }

  /// Prepara los datos para AWS convirtiendo Timestamps a ISO strings.
  Map<String, dynamic> _prepareDataForAWS(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);

    // Convertir Timestamps a ISO strings
    if (result['startTime'] is Timestamp) {
      result['startTime'] =
          (result['startTime'] as Timestamp).toDate().toIso8601String();
    }
    if (result['endTime'] is Timestamp) {
      result['endTime'] =
          (result['endTime'] as Timestamp).toDate().toIso8601String();
    }

    return result;
  }
}
