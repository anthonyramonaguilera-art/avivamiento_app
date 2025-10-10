// lib/utils/app_helpers.dart

import 'package:flutter/material.dart';

/// Devuelve un color específico basado en el rol del usuario.
Color getRoleColor(String role) {
  switch (role) {
    case 'Pastor':
      return Colors.amber.shade800;
    case 'Admin':
      return Colors.red.shade700;
    case 'Líder':
      return Colors.blue.shade700;
    case 'Miembro':
      return Colors.green.shade700;
    default:
      return Colors.grey.shade600;
  }
}
