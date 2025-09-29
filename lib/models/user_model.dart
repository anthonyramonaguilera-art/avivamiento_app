// lib/models/user_model.dart

// Importamos cloud_firestore para poder usar el tipo Timestamp.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para representar los datos de un usuario.
/// Cada propiedad corresponde a un campo en la colección 'users' de Firestore.
class UserModel {
  final String
  id; // ID único del documento (coincide con el UID de Firebase Auth).
  final String nombre;
  final String email;
  final String rol;
  final String? fotoUrl; // La URL de la foto puede ser nula.
  final Timestamp fechaRegistro;

  // Constructor de la clase.
  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fotoUrl,
    required this.fechaRegistro,
  });

  /// Factory constructor para crear una instancia de UserModel desde un mapa (documento de Firestore).
  /// Esto es crucial para convertir los datos crudos de la base deatos en un objeto Dart.
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      nombre:
          data['nombre'] ??
          '', // Usamos '??' para proveer un valor por defecto si el campo es nulo.
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'Invitado', // Por defecto, el rol es 'Invitado'.
      fotoUrl: data['fotoUrl'],
      fechaRegistro: data['fechaRegistro'] ?? Timestamp.now(),
    );
  }

  /// Método para convertir una instancia de UserModel a un mapa.
  /// Esto es necesario para escribir o actualizar datos en Firestore.
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
