// lib/views/home_view/hometab.dart
import 'package:flutter/material.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:health/patient_views/tabs/widgets/home/header_section_home.dart';
import 'package:health/patient_views/tabs/widgets/home/activity_section_home.dart';
import 'package:health/patient_views/tabs/widgets/home/health_metric_section_home.dart';
//import 'package:health/patient_views/tabs/widgets/home/quick_action_section_home.dart';
import 'package:provider/provider.dart';
import '../../helpers/theme_provider.dart';
import '../../controllers/animation/home_animation_controller.dart';

class HomeTab extends StatefulWidget {
  final TickerProvider vsync;
  final HomeAnimations animations;

  const HomeTab({super.key, required this.vsync, required this.animations});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _staggerController;

  Animation<double>? _headerAnimation;
  Animation<double>? _healthMetricsAnimation;
  Animation<double>? _activityAnimation;
  //Animation<double>? _quickActionsAnimation;

  Animation<Offset>? _headerSlideAnimation;
  Animation<Offset>? _healthMetricsSlideAnimation;
  Animation<Offset>? _activitySlideAnimation;
  //Animation<Offset>? _quickActionsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Opacity Animations
    _headerAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _healthMetricsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _activityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );
/* 
    _quickActionsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
*/
    // Slide Animations
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    ));

    _healthMetricsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
    ));

    _activitySlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
    ));

   /* _quickActionsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));*/ 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animations.start();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (user == null) {
      return const SplashScreenViews();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          if (_headerAnimation != null && _headerSlideAnimation != null)
            FadeTransition(
              opacity: _headerAnimation!,
              child: SlideTransition(
                position: _headerSlideAnimation!,
                child: HeaderSection(animations: widget.animations, isdarkMode: isDarkMode),
              ),
            ),
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health metrics
                if (_healthMetricsAnimation != null && _healthMetricsSlideAnimation != null)
                  FadeTransition(
                    opacity: _healthMetricsAnimation!,
                    child: SlideTransition(
                      position: _healthMetricsSlideAnimation!,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _staggerController,
                            curve: const Interval(0.2, 0.5, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: HealthMetricsSection(isDarkMode: isDarkMode, vsync: widget.vsync),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),

                // Recent activity
                if (_activityAnimation != null && _activitySlideAnimation != null)
                  FadeTransition(
                    opacity: _activityAnimation!,
                    child: SlideTransition(
                      position: _activitySlideAnimation!,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _staggerController,
                            curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: ActivitySection(isDarkMode: isDarkMode),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),

                /*
                if (_quickActionsAnimation != null && _quickActionsSlideAnimation != null)
                  FadeTransition(
                    opacity: _quickActionsAnimation!,
                    child: SlideTransition(
                      position: _quickActionsSlideAnimation!,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _staggerController,
                            curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: QuickActionSection(isDarkMode: isDarkMode, vsync: widget.vsync),
                      ),
                    ),
                  ),
                const SizedBox(height: 120), 
                // bottom spacing*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
