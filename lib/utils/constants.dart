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

  /// Rol para musicos del ministerio de alabanza.
  static const String roleMusico = 'Musico';

  /// Rol para danzarinas del ministerio de danza.
  static const String roleDanzarina = 'Danzarina';

  /// Rol especial que indica que el evento es visible para todos.
  static const String roleTodos = 'Todos';

  /// Lista de todos los roles disponibles para ser asignados.
  static const List<String> allRoles = [
    rolePastor,
    roleAdmin,
    roleLider,
    roleMiembro,
    roleMusico,
    roleDanzarina,
    roleInvitado,
  ];

  /// Roles que pueden ser seleccionados como objetivo de eventos.
  static const List<String> eventTargetRoles = [
    roleTodos,
    rolePastor,
    roleLider,
    roleMusico,
    roleDanzarina,
    roleMiembro,
  ];

  /// Leyendas predeterminadas para eventos.
  static const List<Map<String, String>> defaultLegends = [
    {'name': 'Servicio Dominical', 'color': '#FF5252'}, // Rojo vibrante
    {'name': 'Servicio Matutino', 'color': '#FFA726'}, // Naranja
    {'name': 'Servicio de Jóvenes', 'color': '#9C27B0'}, // Púrpura
    {'name': 'Servicio Especial', 'color': '#2196F3'}, // Azul
    {'name': 'Enseñanza Bíblica', 'color': '#4CAF50'}, // Verde
    {'name': 'Ensayo Teatral', 'color': '#E91E63'}, // Rosa
    {'name': 'Ensayo Musical', 'color': '#00BCD4'}, // Cyan
    {'name': 'Conferencia Pastoral', 'color': '#795548'}, // Marrón
  ];
}
