// lib/utils/constants.dart

/// Clase para almacenar constantes globales de la aplicación.
class AppConstants {
  /// Rol para el administrador principal de la aplicación.
  static const String rolePastor = 'Pastor';

  /// Rol para administradores con permisos elevados.
  static const String roleAdmin = 'Admin';

  /// Rol para líderes de ministerios o grupos.
  static const String roleLider = 'Líder';

  /// Rol estándar para un miembro registrado.
  static const String roleMiembro = 'Miembro';

  /// Rol para usuarios no autenticados.
  static const String roleInvitado = 'Invitado';

  /// Lista de todos los roles disponibles para ser asignados.
  static const List<String> allRoles = [
    rolePastor,
    roleAdmin,
    roleLider,
    roleMiembro,
    roleInvitado,
  ];
}