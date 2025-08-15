import 'package:flutter/material.dart';
import '../../../helpers/app_theme.dart';
import '../../../helpers/floating_medical_icons.dart';

class AnimatedBackground extends StatelessWidget {
  final AnimationController backgroundController;
  final bool isDarkMode;

  const AnimatedBackground({
    Key? key,
    required this.backgroundController,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Base gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor(isDarkMode),
                    AppTheme.backgroundColor(isDarkMode).withValues(alpha: 0.9),
                  ]
                ),
              ),
            ),
            // Floating medical icons layer
            FloatingMedicalIcons(
              backgroundController: backgroundController,
              isDarkMode: isDarkMode,
            ),
          ],
        );
      },
    );
  }
}
