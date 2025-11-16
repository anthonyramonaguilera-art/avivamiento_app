// lib/providers/user_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avivamiento_app/models/user_model.dart';
import 'package:avivamiento_app/providers/services_provider.dart';

/// Un StreamProvider que escucha los cambios del perfil del usuario actual.
///
/// Este proveedor es el corazón de la gestión de datos del usuario en la app.
/// Observa el estado de autenticación (`authStateChangesProvider`) y, cuando hay un usuario
/// logueado, obtiene su perfil de Firestore en tiempo real usando `UserService`.
///
/// Ventajas de usar StreamProvider:
/// 1. **Reactivo:** La UI se reconstruirá automáticamente si los datos del usuario cambian en la base de datos.
/// 2. **Gestión de estados:** Maneja automáticamente los estados de carga (loading), datos (data) y error (error).
/// 3. **Eficiente:** Solo se suscribe a los datos cuando un widget lo está escuchando, y se cancela automáticamente.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  // Observamos el proveedor de AuthService para acceder al stream de autenticación.
  final authService = ref.watch(authServiceProvider);
  // Observamos el proveedor de UserService para acceder a los métodos de Firestore.
  final userService = ref.watch(userServiceProvider);

  // Escuchamos los cambios en el estado de autenticación.
  return authService.authStateChanges.asyncMap((user) {
    // Si no hay usuario logueado (user es null), devolvemos null.
    if (user == null) {
      return null;
    }
    // Si hay un usuario, obtenemos su perfil de Firestore usando su UID.
    return userService.getUserProfileStream(user.uid).first;
  });
});
