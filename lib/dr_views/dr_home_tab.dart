import 'package:flutter/material.dart';
import 'package:health/controllers/animation/home_animation_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:health/patient_views/tabs/widgets/home/header_section_home.dart';
import 'package:provider/provider.dart';

class DrHomeTab extends StatefulWidget {
  final TickerProvider vsync;
  final HomeAnimations animations;

  const DrHomeTab({super.key, required this.vsync, required this.animations});

  @override
  State<DrHomeTab> createState() => _DrHomeTabState();
}

class _DrHomeTabState extends State<DrHomeTab> {
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

    if (user == null) {
      return const SplashScreenViews();
    }

    return Center(child: Text('Hi doctor'));
  }
}
