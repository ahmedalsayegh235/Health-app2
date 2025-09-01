import 'package:flutter/material.dart';
import '../../helpers/app_theme.dart';

class DrBottomNav extends StatelessWidget {
  final bool isDarkMode;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AnimationController navAnimationController;

  const DrBottomNav({
    super.key,
    required this.isDarkMode,
    required this.currentIndex,
    required this.onTap,
    required this.navAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navHeight = screenWidth < 400 ? 80.0 : 118.0;
    final iconSize = screenWidth < 400 ? 24.0 : 30.0;
    final iconPadding = screenWidth < 400 ? 4.0 : 8.0;

    return Container(
      height: navHeight,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
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
            navAnimationController
                .forward(from: 0.0) // restart smoothly
                .then((_) => navAnimationController.reverse());
          },
          items: [
            _buildNavItem(
              Icons.calendar_today,
              'Appointment',
              0,
              iconSize,
              iconPadding,
            ),
            _buildNavItem(Icons.home, 'home', 1, iconSize, iconPadding),
            _buildNavItem(
              Icons.chat_bubble_outline,
              'Chat',
              2,
              iconSize,
              iconPadding,
            ),
            // _buildNavItem(Icons.person, 'Profile', 2, iconSize, iconPadding),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    double iconSize,
    double iconPadding,
  ) {
    final isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      icon: isSelected
          ? ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(
                  parent: navAnimationController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: _navIcon(icon, iconSize, iconPadding, true),
            )
          : _navIcon(icon, iconSize, iconPadding, false),
      label: label,
    );
  }

  Widget _navIcon(IconData icon, double size, double padding, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF00E676).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
                color: const Color(0xFF00E676).withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Icon(icon, size: size),
    );
  }
}
