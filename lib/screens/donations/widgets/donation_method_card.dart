// lib/screens/donations/widgets/donation_method_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un widget reutilizable que muestra la información de un método de donación.
/// Incluye la funcionalidad de copiar los datos al portapapeles.
class DonationMethodCard extends StatelessWidget {
  final String title;
  final Map<String, String> details;
  final IconData icon;

  const DonationMethodCard({
    super.key,
    required this.title,
    required this.details,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la tarjeta
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Generamos una fila por cada detalle (Banco, Teléfono, etc.)
            ...details.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Usamos Expanded para que el texto no se desborde
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: '${entry.key}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: entry.value),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón para copiar
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        // Lógica para copiar el valor al portapapeles
                        Clipboard.setData(ClipboardData(text: entry.value));

                        // Mensaje de confirmación (Snackbar)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${entry.key} copiado al portapapeles',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
