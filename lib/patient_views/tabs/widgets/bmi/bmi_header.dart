import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/components/status_indicator.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:provider/provider.dart';

class BmiHeader extends StatelessWidget {
  final bool isDark;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const BmiHeader({super.key, required this.isDark, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    void toggleTheme() {
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.headerGradient(isDark),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(context, user, toggleTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, user, VoidCallback toggleTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (scaffoldKey != null)
          HeaderButton(
            icon: Icons.menu,
            onTap: () => scaffoldKey!.currentState?.openDrawer(),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            iconColor: Colors.white,
            iconSize: 20,
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(12),
          ),
        if (scaffoldKey != null) const SizedBox(width: 12),

        // Greeting + Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user != null && user.name != null && user.name!.isNotEmpty
                          ? 'Hello, ${user.name!.split(' ').first}!'
                          : 'Hello, Guest!',
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const StatusIndicator(), 
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor your BMI here',
                style: TextStyle(
                  decoration: TextDecoration.none, 
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),
        HeaderButton(
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          onTap: toggleTheme,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          iconColor: Colors.white,
          iconSize: 18,
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}