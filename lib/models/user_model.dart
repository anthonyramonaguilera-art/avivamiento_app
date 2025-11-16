// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa el modelo de datos para un usuario en la aplicación.
///
/// Cada instancia de esta clase corresponde a un documento en la colección 'users' de Firestore.
/// Está diseñado para ser inmutable, promoviendo un estado predecible.
class UserModel {
  /// El ID único del documento de Firestore, que debe coincidir con el UID de Firebase Auth.
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? fotoUrl;
  final Timestamp fechaRegistro;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fotoUrl,
    required this.fechaRegistro,
  });

  /// Crea una instancia de [UserModel] a partir de un mapa de datos de Firestore.
  ///
  /// Este factory constructor es crucial para deserializar los datos leídos de la base de datos.
  /// Proporciona valores por defecto para campos que podrían ser nulos.
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'Invitado', // El rol por defecto es 'Invitado'.
      fotoUrl: data['fotoUrl'],
      fechaRegistro: data['fechaRegistro'] ?? Timestamp.now(),
    );
  }

  /// Convierte la instancia de [UserModel] a un mapa para ser almacenado en Firestore.
  ///
  /// Este método es esencial para serializar el objeto Dart antes de escribirlo
  /// en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'fotoUrl': fotoUrl,
      'fechaRegistro': fechaRegistro,
    };
  }
}
