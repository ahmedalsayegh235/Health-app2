import 'package:flutter/material.dart';

class AppTheme {
  //color palette
  static const Color darkgreen = Color(0xFF2D5A3D);
  static const Color lightgreen = Color(0xFF4CAF50);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    primaryColor: const Color(0xFF2D7A32),
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    primaryColor: const Color(0xFF4CAF50),
  );

  static Color backgroundColor(bool isDark) =>
      isDark ? const Color(0xFF0A0E27) : const Color(0xFFF5F7FA);

  static Color cardColor(bool isDark) =>
      isDark ? const Color(0xFF1A1A2E) : Colors.white;

  static Color textColor(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF2C3E50);

  static Color textSecondaryColor(bool isDark) =>
      isDark ? Colors.white60 : Colors.grey[600]!;

  static List<Color> headerGradient(bool isDark) => isDark
      ? [
          const Color(0xFF1B4D3E),
          const Color(0xFF2D7A32),
          const Color(0xFF388E3C),
        ]
      : [
          const Color(0xFF4CAF50),
          const Color(0xFF66BB6A),
          const Color(0xFF81C784),
        ];

  static List<Color> cardGradient(bool isDark) => isDark
      ? [
          const Color(0xFF1A1A2E).withValues(alpha: 0.8),
          const Color(0xFF16213E).withValues(alpha: 0.9),
        ]
      : [Colors.white, const Color(0xFFF8F9FA)];
}
