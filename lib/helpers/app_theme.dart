import 'package:flutter/material.dart';

class AppTheme {
  //color palette
  static const Color darkgreen = Color(0xFF2D5A3D);
  static const Color lightgreen = Color(0xFF4CAF50);

  // Font family
  static const String fontFamily = 'Sora';

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    primaryColor: const Color(0xFF2D7A32),
    fontFamily: fontFamily,
    textTheme: _textTheme(true),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    primaryColor: const Color(0xFF4CAF50),
    fontFamily: fontFamily,
    textTheme: _textTheme(false),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  static ButtonStyle secondaryButtonStyle(bool isDark) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDark ? Colors.white : textColor(isDark),
      side: BorderSide(
        color: isDark
            ? Colors.white.withOpacity(0.3)
            : Colors.grey.withOpacity(0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  static BoxDecoration glassMorphismDecoration(
    bool isDark, {
    double borderRadius = 16,
  }) {
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

  // Apple-inspired typography system
  static TextTheme _textTheme(bool isDark) {
    final baseColor = isDark ? Colors.white : const Color(0xFF2C3E50);

    return TextTheme(
      // Large Title - 34px Bold (for hero numbers like health scores)
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.25,
        height: 1.2,
        color: baseColor,
      ),

      // Title 1 - 28px Bold (for screen titles)
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
        height: 1.3,
        color: baseColor,
      ),

      // Title 2 - 22px Bold (for section headers)
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.3,
        color: baseColor,
      ),

      // Title 3 - 20px SemiBold (for card titles)
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
        color: baseColor,
      ),

      // Headline - 17px SemiBold (for prominent text)
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        height: 1.4,
        color: baseColor,
      ),

      // Body - 17px Regular (for main content)
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        height: 1.5,
        color: baseColor,
      ),

      // Callout - 16px Regular (for secondary content)
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
        height: 1.5,
        color: baseColor,
      ),

      // Subhead - 15px Regular (for labels)
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.16,
        height: 1.4,
        color: baseColor,
      ),

      // Footnote - 13px Regular (for captions)
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        height: 1.4,
        color: isDark ? Colors.white70 : Colors.grey[600],
      ),

      // Caption 1 - 12px Regular (for smallest text)
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.3,
        color: isDark ? Colors.white60 : Colors.grey[600],
      ),

      // Caption 2 - 11px Regular (for tiny labels)
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.06,
        height: 1.3,
        color: isDark ? Colors.white60 : Colors.grey[500],
      ),

      // Title Large - 22px Medium (alternative title style)
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
        color: baseColor,
      ),

      // Title Medium - 16px SemiBold (for card/section titles)
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
        color: baseColor,
      ),

      // Title Small - 14px Medium (for small headers)
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: baseColor,
      ),
    );
  }

  // Quick access text styles for specific use cases

  // Large metric display (e.g., "98" for heart rate)
  static TextStyle metricValue(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
    height: 1.1,
    color: isDark ? Colors.white : const Color(0xFF2C3E50),
  );

  // Medium metric display (e.g., dashboard cards)
  static TextStyle metricValueMedium(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: isDark ? Colors.white : const Color(0xFF2C3E50),
  );

  // Small metric display
  static TextStyle metricValueSmall(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    color: isDark ? Colors.white : const Color(0xFF2C3E50),
  );

  // Metric label (e.g., "BPM", "SpO2")
  static TextStyle metricLabel(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: isDark ? Colors.white60 : Colors.grey[600],
  );

  // Button text
  static TextStyle buttonText(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: Colors.white,
  );

  // Section header
  static TextStyle sectionHeader(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    height: 1.3,
    color: isDark ? Colors.white : const Color(0xFF2C3E50),
  );

  // Card title
  static TextStyle cardTitle(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: isDark ? Colors.white : const Color(0xFF2C3E50),
  );

  // Card subtitle
  static TextStyle cardSubtitle(bool isDark) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: isDark ? Colors.white70 : Colors.grey[700],
  );
}
