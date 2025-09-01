// lib/views/home_view/hometab.dart
import 'package:flutter/material.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/models/user_activity_model.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:health/patient_views/tabs/widgets/home/header_section_home.dart';
import 'package:provider/provider.dart';
import '../../helpers/theme_provider.dart';
import '../../controllers/animation/home_animation_controller.dart';
import 'widgets/home/activity_section_home.dart';
import 'widgets/home/health_metric_section_home.dart';
import 'widgets/home/quick_action_section_home.dart';

class HomeTab extends StatefulWidget {
  final TickerProvider vsync;
  final HomeAnimations animations;

  const HomeTab({super.key, required this.vsync, required this.animations});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<UserActivity> activities = [];



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start animations every time the tab appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animations.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final activityProvider = Provider.of<ActivityProvider>(context);

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
