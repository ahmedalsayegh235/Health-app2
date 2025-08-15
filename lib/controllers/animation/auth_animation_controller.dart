import 'package:flutter/material.dart';

class AuthAnimationController {
  // Animation controllers
  late AnimationController formController;
  late AnimationController slideController;
  late AnimationController backgroundController;
  late AnimationController exitController;

  // Animations
  late Animation<double> formFade;
  late Animation<double> slide;
  late Animation<double> background;
  late Animation<double> exitSlide;

  final TickerProvider vsync;

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

    // Background animation controller for floating medical icons
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
      slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      formController.forward();
    });

    backgroundController.repeat();
  }

  void dispose() {
    formController.dispose();
    slideController.dispose();
    backgroundController.dispose();
    exitController.dispose();
  }
}
