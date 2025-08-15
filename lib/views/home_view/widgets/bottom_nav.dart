import 'package:flutter/material.dart';
import '../../../helpers/app_theme.dart';

class BottomNav extends StatelessWidget {
  final bool isDarkMode;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AnimationController navAnimationController;

  const BottomNav({
    super.key,
    required this.isDarkMode,
    required this.currentIndex,
    required this.onTap,
    required this.navAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF0F1419), const Color(0xFF1A1A2E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: .3)
                : Colors.grey.withValues(alpha: .2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: AppTheme.textSecondaryColor(isDarkMode),
          currentIndex: currentIndex,
          onTap: (index) {
            onTap(index);
            navAnimationController.forward().then((_) {
              navAnimationController.reverse();
            });
          },
          items: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.timeline, 'Activity', 1),
            _buildNavItem(Icons.calendar_today, 'Appointment', 2),
            _buildNavItem(Icons.chat_bubble_outline, 'Chat', 3),
            _buildNavItem(Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: navAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 1 + (navAnimationController.value * 0.2) : 1.0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00E676).withValues(alpha: .1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: .3),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(icon, size: 24),
            ),
          );
        },
      ),
      label: label,
    );
  }
}
