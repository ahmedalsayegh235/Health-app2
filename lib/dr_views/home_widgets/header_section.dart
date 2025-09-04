import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/components/status_indicator.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_theme.dart';
import '../../controllers/animation/home_animation_controller.dart';
import '../../controllers/user_provider.dart';

class DrHeaderSection extends StatelessWidget {
  final HomeAnimations animations;
  final bool isDarkMode;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DrHeaderSection({
    super.key,
    required this.animations,
    required this.isDarkMode,
    this.scaffoldKey,
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
              colors: AppTheme.headerGradient(isDarkMode),
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
                            onTap: () {
                              if (scaffoldKey != null) {
                                scaffoldKey!.currentState?.openDrawer();
                              } else {
                                Scaffold.of(context).openDrawer();
                              }
                            },
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
                              ? 'Welcome Dr. ${user.name!.split(' ').first}'
                              : 'Welcome Doctor',
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
                          icon: isDarkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          onTap: toggleTheme,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  'Ready to help your patients today?',
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
                          'Today\'s Schedule',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Available',
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ],
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