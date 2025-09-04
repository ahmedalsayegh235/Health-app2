import 'package:flutter/material.dart';

class DrAppointmentAnimations {
  late AnimationController headerSlideController;
  late AnimationController listAnimationController;
  late AnimationController fabAnimationController;
  
  late Animation<Offset> headerSlideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> listFadeAnimation;
  late Animation<Offset> listSlideAnimation;
  late Animation<double> fabScaleAnimation;
  late Animation<double> fabRotationAnimation;
  
  final TickerProvider vsync;

  DrAppointmentAnimations(this.vsync) {
    _setupControllers();
    _setupAnimations();
  }

  void _setupControllers() {
    headerSlideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
  }

  void _setupAnimations() {
    headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: headerSlideController,
      curve: Curves.easeOutCubic,
    ));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: headerSlideController,
      curve: Curves.easeOutCubic,
    ));

    listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    listSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fabAnimationController,
      curve: Curves.elasticOut,
    ));

    fabRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fabAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void start() {
    // Reset all controllers
    headerSlideController.reset();
    listAnimationController.reset();
    fabAnimationController.reset();

    // Start header animation
    headerSlideController.forward();

    // Start list animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      listAnimationController.forward();
    });

    // Start FAB animation
    Future.delayed(const Duration(milliseconds: 600), () {
      fabAnimationController.forward();
    });
  }

  void reset() {
    headerSlideController.reset();
    listAnimationController.reset();
    fabAnimationController.reset();
  }

  void dispose() {
    headerSlideController.dispose();
    listAnimationController.dispose();
    fabAnimationController.dispose();
  }
}