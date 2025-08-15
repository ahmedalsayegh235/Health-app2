import 'package:flutter/material.dart';
import '../../../helpers/app_theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDarkMode;
  final AnimationController? animationController;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDarkMode,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = animationController;

    return GestureDetector(
      onTapDown: (_) => controller?.forward(),
      onTapUp: (_) => controller?.reverse(),
      onTapCancel: () => controller?.reverse(),
      child: AnimatedBuilder(
        animation: controller ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          double scale = 1 - ((controller?.value ?? 0) * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withOpacity(isDarkMode ? 0.1 : 0.05),
                    iconColor.withOpacity(isDarkMode ? 0.05 : 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(isDarkMode),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
