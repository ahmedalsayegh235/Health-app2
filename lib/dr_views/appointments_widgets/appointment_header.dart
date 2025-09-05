import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:provider/provider.dart';

class DrAppointmentHeader extends StatelessWidget {
  final bool isDark;
  final TabController tabController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map<String, int> stats;
  final VoidCallback onCreateAppointment;
  final VoidCallback onCleanup;

  const DrAppointmentHeader({
    super.key,
    required this.isDark,
    required this.tabController,
    required this.scaffoldKey,
    required this.stats,
    required this.onCreateAppointment,
    required this.onCleanup,
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
              // Top row: Drawer, Greeting, Actions
              Row(
                children: [
                  HeaderButton(
                    icon: Icons.menu,
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                    backgroundColor: Colors.white.withValues(alpha: .1),
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
                              ? 'Dr. ${user.name!.split(' ').first}'
                              : 'Doctor Dashboard',
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
                            color: Colors.white.withValues(alpha:0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  HeaderButton(
                    icon: Icons.cleaning_services,
                    onTap: onCleanup,
                    backgroundColor: Colors.white.withValues(alpha:0.1),
                    iconColor: Colors.white,
                  ),
                  HeaderButton(
                    icon: Icons.add_circle_outline,
                    onTap: onCreateAppointment,
                    backgroundColor: Colors.white.withValues(alpha:0.1),
                    iconColor: Colors.white,
                  ),
                  HeaderButton(
                    icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    onTap: toggleTheme,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Statistics cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.event_available,
                      title: '${stats['available'] ?? 0}',
                      subtitle: 'Available',
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions,
                      title: '${stats['pending'] ?? 0}',
                      subtitle: 'Pending',
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      title: '${stats['booked'] ?? 0}',
                      subtitle: 'Booked',
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Modern Tab Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.16),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withValues(alpha:0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha:0.7),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 9,
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
                      text: 'Pending',
                      icon: Icon(Icons.pending_actions, size: 16),
                    ),
                    Tab(
                      text: 'Booked',
                      icon: Icon(Icons.check_circle, size: 16),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.16),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.7),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}