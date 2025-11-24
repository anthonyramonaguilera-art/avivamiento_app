// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/auth_wrapper.dart'; // Usamos la importación relativa

/// SplashScreen: La pantalla de bienvenida de la aplicación.
///
/// Muestra el logo de la iglesia con una animación de entrada y,
/// después de una breve duración, navega al AuthWrapper.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// El controlador para la animación de entrada.
  late AnimationController _controller;

  /// La animación que controla la posición vertical del logo (descenso).
  late Animation<double> _slideAnimation;

  /// La animación que controla la escala del logo (un pequeño 'latido' al llegar).
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animación de descenso con un efecto de rebote al final.
    _slideAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    // Un pequeño 'latido' o 'pulso' que ocurre una sola vez al llegar.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Iniciamos la animación de entrada.
    _controller.forward();

    // Navegamos a la siguiente pantalla después de un breve retraso.
    _navigateToNextScreen();
  }

  /// Navega al AuthWrapper después de la duración del splash.
  void _navigateToNextScreen() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              // El descenso es 30% de la altura de la pantalla.
              offset: Offset(
                0.0,
                _slideAnimation.value *
                    MediaQuery.of(context).size.height *
                    0.3,
              ),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Image.asset('assets/images/logo.png', width: 150),
        ),
      ),
    );
  }
}
