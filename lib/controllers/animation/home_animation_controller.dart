import 'package:flutter/material.dart';

class HomeAnimations {
  late AnimationController navAnimationController;
  late AnimationController scoreAnimationController;
  late AnimationController buttonAnimationController;
  late AnimationController headerSlideController;

  late Animation<double> scoreAnimation;
  late Animation<Offset> headerSlideAnimation;
  late Animation<double> fadeAnimation;

  HomeAnimations(TickerProvider vsync) {
    navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    )..repeat();

    scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: vsync,
    );

    headerSlideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );

    scoreAnimation = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(
        parent: scoreAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: headerSlideController,
            curve: Curves.easeOutCubic,
          ),
        );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: headerSlideController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void start() {
    headerSlideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      scoreAnimationController.forward();
    });
  }

  void dispose() {
    navAnimationController.dispose();
    scoreAnimationController.dispose();
    buttonAnimationController.dispose();
    headerSlideController.dispose();
  }
}
