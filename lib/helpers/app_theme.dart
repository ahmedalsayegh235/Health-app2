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

      // Status colors
  static const Color successColor = Color(0xFF66BB6A);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color infoColor = Color(0xFF42A5F5);

  // Additional utility colors
  static Color dividerColor(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3);

  static Color shadowColor(bool isDark) =>
      isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);

  // Button styles
  static ButtonStyle primaryButtonStyle(bool isDark) {
    return ElevatedButton.styleFrom(
      backgroundColor: lightgreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: lightgreen.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  static ButtonStyle secondaryButtonStyle(bool isDark) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDark ? Colors.white : textColor(isDark),
      side: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.withOpacity(0.5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Input decoration
  static InputDecoration inputDecoration(bool isDark, String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: textSecondaryColor(isDark)),
      filled: true,
      fillColor: cardColor(isDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightgreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration(bool isDark, {double borderRadius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: cardGradient(isDark),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowColor(isDark),
          blurRadius: 12,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: isDark 
            ? Colors.white.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // Glass morphism effect
  static BoxDecoration glassMorphismDecoration(bool isDark, {double borderRadius = 16}) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.3),
      ),
      boxShadow: [
        BoxShadow(
          color: shadowColor(isDark),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Common curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
}
