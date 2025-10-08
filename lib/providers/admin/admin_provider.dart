// lib/providers/admin/admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que expone la lista completa de usuarios.
///
/// Este provider será utilizado por el Panel de Administración para mostrar
/// a todos los miembros de la aplicación y poder gestionar sus roles.
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  // Escucha al UserService para acceder a su método.
  final userService = ref.watch(userServiceProvider);
  // Devuelve el stream que obtiene todos los usuarios.
  return userService.getAllUsersStream();
});