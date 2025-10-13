// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:avivamiento_app/screens/auth_screen.dart'; // Asegúrate de que esta ruta sea correcta

/// SplashScreen: La pantalla de bienvenida de la aplicación.
///
/// Muestra el logo de la iglesia con una animación de entrada y,
/// después de una breve duración, navega a la pantalla de autenticación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// El controlador para nuestra animación.
  ///
  /// [AnimationController] nos permite controlar la duración,
  /// el estado (iniciar, detener, repetir) y la dirección de la animación.
  late AnimationController _controller;

  /// La animación que controla la posición vertical del logo (descenso).
  ///
  /// Un [Animation<double>] es un valor que puede cambiar con el tiempo.
  /// Usamos un [Tween] para definir el rango de valores (de -1.0 a 0.0).
  late Animation<double> _slideAnimation;

  /// La animación que controla la escala del logo (efecto de pulso).
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializamos el AnimationController.
    // La duración total de la animación será de 2 segundos.
    // 'vsync: this' es necesario para que Flutter sincronice la animación
    // con la tasa de refresco de la pantalla, evitando un consumo innecesario
    // de recursos.
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Definimos la animación de descenso.
    // Usamos un CurvedAnimation con Curves.bounceOut para un efecto de rebote al final.
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    // Definimos la animación de pulso (escala).
    // El logo se escalará de 1.0 a 1.1 y volverá a 1.0.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Iniciamos la animación.
    _controller.forward();

    // Navegamos a la siguiente pantalla después de un retraso.
    _navigateToAuth();
  }

  /// Navega a la pantalla de autenticación después de la duración del splash.
  void _navigateToAuth() {
    Timer(const Duration(milliseconds: 2500), () {
      // Usamos pushReplacement para que el usuario no pueda volver al splash screen
      // presionando el botón de retroceso.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
        ), // Asegúrate que AuthScreen existe
      );
    });
  }

  @override
  void dispose() {
    // Es crucial liberar los recursos del controlador para evitar fugas de memoria.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un color de fondo acorde a un tema minimalista.
      backgroundColor: Colors.white,
      body: Center(
        // AnimatedBuilder es un widget optimizado para construir animaciones.
        // Solo reconstruye los widgets que dependen de la animación,
        // en lugar de todo el árbol de widgets.
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              // El offset vertical se controla con _slideAnimation.
              // Multiplicamos por la altura de la pantalla para que el descenso
              // sea relativo al tamaño del dispositivo.
              offset: Offset(
                0.0,
                _slideAnimation.value *
                    MediaQuery.of(context).size.height *
                    0.3,
              ),
              child: Transform.scale(
                // La escala se controla con _scaleAnimation para el efecto de pulso.
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          // Este es el 'child' que se pasa al 'builder' de AnimatedBuilder.
          // Es nuestro logo. No se reconstruye en cada frame de la animación.
          child: Image.asset(
            'assets/images/logo.png',
            width: 150, // Ajusta el tamaño según sea necesario
          ),
        ),
      ),
    );
  }
}
