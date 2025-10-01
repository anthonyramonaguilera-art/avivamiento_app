// lib/screens/donations/donations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/donation_method_card.dart';

/// Pantalla que muestra los diferentes métodos para realizar donaciones.
class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un ListView para que la pantalla sea desplazable si hay mucho contenido.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Apoya a la Obra',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu generosidad nos permite continuar expandiendo el mensaje. A continuación, te presentamos las formas en las que puedes sembrar en este ministerio.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Tarjeta para Pago Móvil (con datos de ejemplo)
          DonationMethodCard(
            title: 'Pago Móvil',
            details: const {
              'Banco': '0102 - Banco de Venezuela',
              'Teléfono': '0414-1234567',
              'RIF': 'J-12345678-9',
            },
            icon: Icons.phone_android,
          ),

          const SizedBox(height: 16),

          // Tarjeta para Transferencia Bancaria (con datos de ejemplo)
          DonationMethodCard(
            title: 'Transferencia Bancaria',
            details: const {
              'Banco': 'Bancamiga',
              'Titular': 'Centro Internacional Avivamiento',
              'Cuenta': '0171-0012-3456-7890-1234',
              'RIF': 'J-12345678-9',
            },
            icon: Icons.account_balance,
          ),

          const SizedBox(height: 16),

          // Tarjeta para PayPal (con datos de ejemplo)
          DonationMethodCard(
            title: 'PayPal',
            details: const {'Correo': 'donaciones@avivamiento.org'},
            icon: Icons.paypal,
          ),
        ],
      ),
    );
  }
}
