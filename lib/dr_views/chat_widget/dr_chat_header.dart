import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/components/status_indicator.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:provider/provider.dart';

class DrChatHeader extends StatelessWidget {
  final bool isDark;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DrChatHeader({
    super.key,
    required this.isDark,
    this.scaffoldKey,
  });

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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(context, user, toggleTheme),
                const SizedBox(height: 24),
              ],
            ),
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
            backgroundColor: Colors.white.withValues(alpha: .15),
            iconColor: Colors.white,
            iconSize: 20,
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(12),
          ),
        if (scaffoldKey != null) const SizedBox(width: 12),

        // Greeting + Status for Doctor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user != null && user.name != null && user.name!.isNotEmpty
                          ? 'Hello, Dr. ${user.name!.split(' ').first}!'
                          : 'Hello, Doctor!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const StatusIndicator(), // <- Now right next to the greeting
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Manage patient consultations',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: .85),
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
          backgroundColor: Colors.white.withValues(alpha: .15),
          iconColor: Colors.white,
          iconSize: 18,
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(width: 8),
        HeaderButton(
          icon: Icons.notifications_outlined,
          onTap: () => _showNotificationsDialog(context),
          backgroundColor: Colors.white.withValues(alpha: .15),
          iconColor: Colors.white,
          iconSize: 18,
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final isDark = this.isDark;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_outlined, color: AppTheme.lightgreen, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade800.withValues(alpha: .5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightgreen.withValues(alpha: .3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: AppTheme.textSecondaryColor(isDark),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor(isDark),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppTheme.headerGradient(isDark)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
