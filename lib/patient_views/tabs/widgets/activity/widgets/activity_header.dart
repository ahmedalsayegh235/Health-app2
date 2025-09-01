import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/components/status_indicator.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/providers/sensor_provider.dart';
import 'package:health/providers/user_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/header/stat_widget.dart';
import 'package:provider/provider.dart';

class ActivityHeader extends StatelessWidget {
  final bool isDark;
  final TabController tabController;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ActivityHeader({
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
              // Top row: Drawer, Status, Greeting, Theme & Notification buttons
              Row(
                children: [
                  HeaderButton(
                    icon: Icons.menu,
                    onTap: () {
                      // Open the drawer using the scaffold key
                      scaffoldKey.currentState?.openDrawer();
                    },
                    backgroundColor: Colors.white.withOpacity(0.1),
                    iconColor: Colors.white,
                    iconSize: 20,
                    padding: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 16),
                  StatusIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user != null && user.name != null && user.name!.isNotEmpty
                          ? 'Welcome back, ${user.name!.split(' ').first}'
                          : 'Welcome back guest',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  HeaderButton(
                    icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    onTap: toggleTheme,
                  ),
                  HeaderButton(
                    icon: Icons.notification_add_outlined,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick stats row
              Row(
                children: [
                  Expanded(
                    child: Consumer<SensorProvider>(
                      builder: (context, sensorProvider, child) {
                        final currentBpm = sensorProvider.latest.heartRate.toInt();
                        return StatsWidget(
                          icon: Icons.favorite_border,
                          value: currentBpm > 0 ? currentBpm.toString() : '--',
                          label: 'BPM',
                          color: const Color(0xFFFF6B6B),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<SensorProvider>(
                      builder: (context, sensorProvider, child) {
                        final currentSpo2 = sensorProvider.latest.spo2;
                        return StatsWidget(
                          icon: Icons.air,
                          value: currentSpo2 > 0 ? '$currentSpo2%' : '--',
                          label: 'SpO2',
                          color: const Color(0xFF4ECDC4),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsWidget(
                      icon: Icons.show_chart,
                      value: 'Normal',
                      label: 'ECG',
                      color: const Color(0xFF45B7D1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Modern Tab Bar
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
                    Tab(text: 'Heart Rate'),
                    Tab(text: 'SpO2'),
                    Tab(text: 'ECG'),
                    Tab(text: 'Devices'),
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
