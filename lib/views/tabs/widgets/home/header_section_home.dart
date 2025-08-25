import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/components/status_indicator.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/views/widgets/scorebar_widget.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/app_theme.dart';
import '../../../../controllers/animation/home_animation_controller.dart';
import '../../../../providers/user_provider.dart';

class HeaderSection extends StatelessWidget {
  final HomeAnimations animations;
  final bool isdarkMode;

  const HeaderSection({
    super.key,
    required this.animations,
    required this.isdarkMode,
  });

  @override
  Widget build(BuildContext context) {
    void toggleTheme() {
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    }

    final user = Provider.of<UserProvider>(context).user;

    return SlideTransition(
      position: animations.headerSlideAnimation,
      child: FadeTransition(
        opacity: animations.fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.headerGradient(isdarkMode),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => HeaderButton(
                            icon: Icons.menu,
                            onTap: () => Scaffold.of(context).openDrawer(),
                            backgroundColor: Colors.white.withValues(alpha: .1),
                            iconColor: Colors.white,
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const SizedBox(width: 8),

                        StatusIndicator(),
                        const SizedBox(width: 8),
                        Text(
                          user != null &&
                                  user.name != null &&
                                  user.name!.isNotEmpty
                              ? 'Welcome back, ${user.name!.split(' ').first}'
                              : 'Welcome back guest', // just incase firebase becomes dumb
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        HeaderButton(
                          icon: isdarkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          onTap: toggleTheme,
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            HeaderButton(
                              icon: Icons.notifications_outlined,
                              onTap: () {},
                            ),
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF1744),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Health Score',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              '100/100',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ScoreBar(animation: animations.scoreAnimation),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Last Updated',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '2 minutes ago',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
