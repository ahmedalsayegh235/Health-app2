import 'package:flutter/material.dart';
import 'package:health/controllers/animation/auth_animation_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/views/auth_view/widgets/animated_background.dart';
import 'package:provider/provider.dart';


class SplashScreenViews extends StatefulWidget {
  const SplashScreenViews({super.key});

  @override
  State<SplashScreenViews> createState() => _SplashScreenViewsState();
}

class _SplashScreenViewsState extends State<SplashScreenViews>
    with TickerProviderStateMixin {
  late AuthAnimationController _authAnimationController;

  @override
  void initState() {
    super.initState();
    _authAnimationController = AuthAnimationController(vsync: this);
    _authAnimationController.startAnimations();

    // Optional: Navigate after a delay
    Future.delayed(const Duration(seconds: 3), () async {
      await _authAnimationController.exitController.forward();
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  @override
  void dispose() {
    _authAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            backgroundController: _authAnimationController.backgroundController,
            isDarkMode: isDarkMode,
          ),

          //Splash screen 
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.asset(
                        'assets/images/splash_screen_logo.png',
                        fit: BoxFit.contain,
                        height: 150,
                        width: 150,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        color: Colors.green,
                        backgroundColor: Colors.white.withValues(alpha: .3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
