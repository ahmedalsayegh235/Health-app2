import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AppointmentHeader extends StatelessWidget {
  final bool isDark;
  final TabController tabController;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppointmentHeader({
    super.key,
    required this.isDark,
    required this.tabController,
    required this.scaffoldKey,
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // Top row: Drawer, Greeting, Theme button
              Row(
                children: [
                  HeaderButton(
                    icon: Icons.menu,
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    backgroundColor: Colors.white.withOpacity(0.1),
                    iconColor: Colors.white,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null && user.name != null && user.name!.isNotEmpty
                              ? 'Hello, ${user.name!.split(' ').first}!'
                              : 'Hello, Guest!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your appointments',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HeaderButton(
                    icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    onTap: toggleTheme,
                  ),
                  HeaderButton(
                    icon: Icons.calendar_today,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tab Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      text: 'Available',
                      icon: Icon(Icons.event_available, size: 16),
                    ),
                    Tab(
                      text: 'My Appointments',
                      icon: Icon(Icons.person_pin_circle, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}