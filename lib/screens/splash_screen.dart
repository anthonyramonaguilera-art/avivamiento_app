// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';

// [CAMBIO] Importamos el nuevo AuthWrapper.
import '../widgets/auth_wrapper.dart';

/// SplashScreen: La pantalla de bienvenida de la aplicación.
/// Muestra el logo con animación y navega al AuthWrapper.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

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

    _controller.forward();
    _navigateToNextScreen();
  }

  /// Navega a la pantalla correspondiente después de la animación.
  void _navigateToNextScreen() {
    Timer(const Duration(milliseconds: 2500), () {
      // Usamos pushReplacement para que el usuario no pueda volver al splash screen.
      Navigator.of(context).pushReplacement(
        // [CAMBIO] Navegamos al AuthWrapper en lugar de directamente a AuthScreen.
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
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
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
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
