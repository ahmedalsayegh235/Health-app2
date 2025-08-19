// lib/views/home_view/hometab.dart
import 'package:flutter/material.dart';
import 'package:health/providers/user_provider.dart';
import 'package:health/views/splash_screen_views.dart';
import 'package:health/views/tabs/widgets/header_section.dart';
import 'package:provider/provider.dart';
import '../../helpers/theme_provider.dart';
import '../../controllers/animation/home_animation_controller.dart';
import 'widgets/activity_section.dart';
import 'widgets/health_metric_section.dart';
import 'widgets/quick_action_section.dart';

class HomeTab extends StatefulWidget {
  final TickerProvider vsync;
  final HomeAnimations animations;

  const HomeTab({super.key, required this.vsync, required this.animations});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (user == null) {
      return const SplashScreenViews();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- HEADER ----------------
          HeaderSection(animations: widget.animations, isdarkMode: isDarkMode),
          const SizedBox(height: 30),

          // ---------------- BODY CONTENT ----------------
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health metrics
                  HealthMetricsSection(
                    isDarkMode: isDarkMode,
                    vsync: widget.vsync,
                  ),
                  const SizedBox(height: 40),
                  // Recent activity
                  ActivitySection(
                    isDarkMode: isDarkMode,
                    activities: [
                      {
                        'icon': Icons.favorite,
                        'iconColor': const Color(0xFF00E676),
                        'title': 'Heart rate measured',
                        'time': '2 minutes ago',
                        'onTap': () {},
                      },
                      {
                        'icon': Icons.calendar_today,
                        'iconColor': const Color(0xFF2196F3),
                        'title': 'Appointment reminder',
                        'time': '1 hour ago',
                        'onTap': () {},
                      },
                      {
                        'icon': Icons.mail_outline,
                        'iconColor': const Color(0xFF9C27B0),
                        'title': 'New message from Dr. Smith',
                        'time': '3 hours ago',
                        'onTap': () {},
                      },
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Quick actions
                  QuickActionSection(
                    isDarkMode: isDarkMode,
                    vsync: widget.vsync,
                  ),
                  const SizedBox(height: 120), // space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
