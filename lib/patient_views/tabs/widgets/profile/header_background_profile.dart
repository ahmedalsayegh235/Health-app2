import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';

class HeaderBackground extends StatelessWidget {
  const HeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.headerGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
