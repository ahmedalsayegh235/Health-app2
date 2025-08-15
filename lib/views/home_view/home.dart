import 'package:flutter/material.dart';
import 'package:health/views/home_view/widgets/scorebar_widget.dart';
import '../../helpers/app_theme.dart';
import '../../controllers/animation/home_animation_controller.dart';
import '../../components/custom_drawer.dart';
import '../../components/custom_header_button.dart';
import '../../views/home_view/widgets/metric_card.dart';
import '../../views/home_view/widgets/activity.dart';
import '../../views/home_view/widgets/quick_action_card.dart';
import '../../views/home_view/widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  bool _isDarkMode = false;
  late HomeAnimations _animations;

  void initState() {
    super.initState();
    _animations = HomeAnimations(this);
    _animations.start();
  }

  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(_isDarkMode),
        drawer: CustomDrawer(
          isDarkMode: _isDarkMode,
          onItemTap: (title) {
            // TODO: Handle the stupid drawer item tap
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Header Section
                SlideTransition(
                  position: _animations.headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _animations.fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppTheme.headerGradient(_isDarkMode),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) => GestureDetector(
                                        onTap: () =>
                                            Scaffold.of(context).openDrawer(),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.menu,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00E676),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Good Morning, Ahmed',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Dark mode toggle
                                    HeaderButton(
                                      icon: _isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      onTap: () {
                                        setState(() {
                                          _isDarkMode = !_isDarkMode;
                                        });
                                      },
                                    ),

                                    // Notifications with badge
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        HeaderButton(
                                          icon: Icons.notifications_outlined,
                                          onTap: () {
                                            // Your notification logic
                                          },
                                        ),
                                        // Red badge
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
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          '85/100',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ScoreBar(
                                          animation: _animations.scoreAnimation,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Last Updated',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '2 minutes ago',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
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
                ),

                const SizedBox(height: 30),

                // Health Metrics Section (Only 3 cards)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Metrics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(_isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Single row with 3 metrics
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              icon: Icons.favorite_outline,
                              iconColor: const Color(0xFF00E676),
                              title: 'Heart Rate',
                              value: '72',
                              unit: 'bpm',
                              change: '0%',
                              isPositive: true,
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.water_drop_outlined,
                              iconColor: const Color(0xFF00BCD4),
                              title: 'Blood Oxygen',
                              value: '98',
                              unit: '%',
                              change: '+1%',
                              isPositive: true,
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.monitor_weight_outlined,
                              iconColor: const Color(0xFF7C4DFF),
                              title: 'Weight',
                              value: '70',
                              unit: 'Kg',
                              change: '+0.5%',
                              isPositive: true,
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(_isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ActivityItem(
                        icon: Icons.favorite,
                        iconColor: const Color(0xFF00E676),
                        title: 'Heart rate measured',
                        time: '2 minutes ago',
                        isDarkMode: _isDarkMode,
                      ),

                      ActivityItem(
                        icon: Icons.calendar_today,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Appointment reminder',
                        time: '1 hour ago',
                        isDarkMode: _isDarkMode,
                      ),

                      ActivityItem(
                        icon: Icons.mail_outline,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'New message from Dr. Smith',
                        time: '3 hours ago',
                        isDarkMode: _isDarkMode,
                      ),

                      const SizedBox(height: 40),

                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(_isDarkMode),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.add_circle_outline,
                              iconColor: const Color(0xFF00E676),
                              title: 'Record Vitals',
                              isDarkMode: _isDarkMode,
                              animationController:
                                  _animations.buttonAnimationController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.assessment_outlined,
                              iconColor: const Color(0xFF2196F3),
                              title: 'View Reports',
                              isDarkMode: _isDarkMode,
                              animationController:
                                  _animations.buttonAnimationController,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 120,
                      ), // Space for bottom navigation
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNav(
          isDarkMode: _isDarkMode,
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
          navAnimationController: _animations.navAnimationController,
        ),
      ),
    );
  }
}
