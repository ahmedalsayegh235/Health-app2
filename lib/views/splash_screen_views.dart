import 'package:flutter/material.dart';

class SplashScreenViews extends StatelessWidget {
  const SplashScreenViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Color(0xFFB6EAC7),  // Set background color here
  body: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(75), // Circular logo
                    child: Image.asset(
                      'assets/images/splash_screen_logo.png',
                      fit: BoxFit.contain,
                      height: 150,
                      width: 150,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Customized CircularProgressIndicator
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
  ),
);

  }
}
  