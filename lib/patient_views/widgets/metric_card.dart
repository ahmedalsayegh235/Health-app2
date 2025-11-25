import 'package:flutter/material.dart';
import '../../helpers/app_theme.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double value;
  final double previousValue;
  final String unit;
  final bool isDarkMode;
  final AnimationController? animationController;
  final VoidCallback? onTap; // For navigation

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.isDarkMode,
    this.animationController,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = animationController;

    // Auto calculate change
    final double diff = value - previousValue;
    final double percentChange = previousValue == 0
        ? 0
        : (diff / previousValue) * 100;
    final bool isPositive = diff >= 0;

    return GestureDetector(
      onTapDown: (_) => controller?.forward(),
      onTapUp: (_) {
        controller?.reverse();
        if (onTap != null) onTap!(); // Navigate when tapped
      },
      onTapCancel: () => controller?.reverse(),
      child: AnimatedBuilder(
        animation: controller ?? const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          double scale = 1 - ((controller?.value ?? 0) * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppTheme.cardGradient(isDarkMode),
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? iconColor.withValues(alpha: .3)
                      : Colors.grey.withValues(alpha: .2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? iconColor.withValues(alpha: .1)
                        : Colors.grey.withValues(alpha: .1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Icon + Change %
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: iconColor.withValues(alpha: .3),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, color: iconColor, size: 19),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.red)
                              .withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isPositive ? Colors.green : Colors.red)
                                .withValues(alpha: .3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 8,
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11.5,
                      color: AppTheme.textSecondaryColor(isDarkMode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Value + unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(isDarkMode),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 8,
                          color: AppTheme.textSecondaryColor(isDarkMode),
                        ),
                      ),
                    ],
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
