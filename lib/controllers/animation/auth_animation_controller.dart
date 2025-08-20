import 'package:flutter/material.dart';

class AuthAnimationController {
  // Animation controllers
  late final AnimationController formController;
  late final AnimationController slideController;
  late final AnimationController backgroundController;
  late final AnimationController exitController;

  // Animations
  late final Animation<double> formFade;
  late final Animation<double> slide;
  late final Animation<double> background;
  late final Animation<double> exitSlide;

  final TickerProvider vsync;
  bool _isDisposed = false;

  AuthAnimationController({required this.vsync}) {
    _setupAnimations();
  }

  void _setupAnimations() {
    // Form animation controller
    formController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    // Slide animation controller
    slideController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: vsync,
    );

    // Background animation controller
    backgroundController = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: vsync,
    );

    // Exit animation controller
    exitController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    // Animations
    formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: formController, curve: Curves.easeIn),
    );

    slide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic),
    );

    background = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: backgroundController, curve: Curves.linear),
    );

    exitSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: exitController, curve: Curves.easeInCubic),
    );
  }

  void startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isDisposed) slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_isDisposed) formController.forward();
    });

    if (!_isDisposed) {
      backgroundController.repeat();
    }
  }

  void dispose() {
    _isDisposed = true;
    formController.dispose();
    slideController.dispose();
    backgroundController.dispose();
    exitController.dispose();
  }
}
