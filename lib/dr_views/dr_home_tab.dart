import 'package:flutter/material.dart';
import 'package:health/controllers/animation/home_animation_controller.dart';
import 'package:health/dr_views/home_widgets/header_section.dart';
import 'package:health/dr_views/home_widgets/next_app.dart';
import 'package:health/dr_views/home_widgets/quick_action.dart';
import 'package:health/dr_views/home_widgets/stats.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_theme.dart';

class DrHomeTab extends StatefulWidget {
  final TickerProvider vsync;
  final HomeAnimations animations;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DrHomeTab({
    super.key,
    required this.vsync,
    required this.animations,
    this.scaffoldKey,
  });

  @override
  State<DrHomeTab> createState() => _DrHomeTabState();
}

class _DrHomeTabState extends State<DrHomeTab>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;

  Animation<double>? _headerAnimation;
  Animation<double>? _statsAnimation;
  Animation<double>? _appointmentAnimation;
  Animation<double>? _quickActionsAnimation;

  Animation<Offset>? _headerSlideAnimation;
  Animation<Offset>? _statsSlideAnimation;
  Animation<Offset>? _appointmentSlideAnimation;
  Animation<Offset>? _quickActionsSlideAnimation;

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

    _headerAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _statsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _appointmentAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _quickActionsAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _statsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _appointmentSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _quickActionsSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.animations.start();
      _startStaggeredAnimations();
    });
  }

  void _startStaggeredAnimations() {
    _staggerController.reset();
    _staggerController.forward();
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (_headerAnimation != null && _headerSlideAnimation != null)
              FadeTransition(
                opacity: _headerAnimation!,
                child: SlideTransition(
                  position: _headerSlideAnimation!,
                  child: DrHeaderSection(
                    animations: widget.animations,
                    isDarkMode: isDarkMode,
                    scaffoldKey: widget.scaffoldKey,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_statsAnimation != null && _statsSlideAnimation != null)
                    FadeTransition(
                      opacity: _statsAnimation!,
                      child: SlideTransition(
                        position: _statsSlideAnimation!,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _staggerController,
                              curve: const Interval(0.2, 0.5, curve: Curves.easeOutBack),
                            ),
                          ),
                          child: DrStatsGrid(isDarkMode: isDarkMode),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (_appointmentAnimation != null && _appointmentSlideAnimation != null)
                    FadeTransition(
                      opacity: _appointmentAnimation!,
                      child: SlideTransition(
                        position: _appointmentSlideAnimation!,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _staggerController,
                              curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
                            ),
                          ),
                          child: DrNextAppointmentCard(isDarkMode: isDarkMode),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

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
                          child: DrQuickActions(isDarkMode: isDarkMode),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
