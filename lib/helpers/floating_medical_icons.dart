import 'dart:math';
import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';

class FloatingMedicalIcons extends StatelessWidget {
  final AnimationController backgroundController;
  final bool isDarkMode;

  const FloatingMedicalIcons({
    Key? key,
    required this.backgroundController,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = Random(42); 

    List<Widget> icons = [];

    // Generate 30 icons with random parameters
    for (int i = 0; i < 100; i++) {
      // Randomize base position, movement amplitude, speed, and opacity
      double baseX = random.nextDouble() * (screenWidth - 60);
      double baseY = random.nextDouble() * (screenHeight - 60);
      double amplitudeX = 30 + random.nextDouble() * 30;
      double amplitudeY = 30 + random.nextDouble() * 30;
      double speed = 0.7 + random.nextDouble() * 1.0;
      double opacityBase = 0.4 + random.nextDouble() * 0.5;
      double opacitySpeed = 0.5 + random.nextDouble() * 1.0;
      List<IconData> medicalIcons = [
        Icons.medical_services,
        Icons.healing,
        Icons.local_hospital,
        Icons.monitor_heart,
        Icons.vaccines,
      ];
      IconData icon = medicalIcons[i % medicalIcons.length];

      icons.add(_buildFloatingIcon(
        context,
        icon,
        baseX,
        baseY,
        amplitudeX,
        amplitudeY,
        speed,
        opacityBase,
        opacitySpeed,
        i,
      ));
    }

    return Stack(children: icons);
  }

  Widget _buildFloatingIcon(
    BuildContext context,
    IconData icon,
    double baseX,
    double baseY,
    double amplitudeX,
    double amplitudeY,
    double speed,
    double opacityBase,
    double opacitySpeed,
    int seed,
  ) {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        double t = backgroundController.value;

        // Each icon gets a unique phase offset for randomness
        double phase = seed * pi / 8;

        // Floating around the screen in a smooth, slow, random pattern
        double x = baseX + sin((t * speed + phase) * 2 * pi) * amplitudeX;
        double y = baseY + cos((t * speed + phase) * 2 * pi) * amplitudeY;

        // Clamp to keep icons on screen
        double finalX = x.clamp(0.0, MediaQuery.of(context).size.width - 50);
        double finalY = y.clamp(0.0, MediaQuery.of(context).size.height - 50);

        // Random opacity, smoothly animated
        double opacity = opacityBase +
            sin((t * opacitySpeed + phase) * 2 * pi) * 0.3;
        opacity = opacity.clamp(0.2, 1.0);

        return Positioned(
          left: finalX,
          top: finalY,
          child: Opacity(
            opacity: opacity,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.headerGradient(isDarkMode),
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}