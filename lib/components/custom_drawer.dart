import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final Function(String) onItemTap;

  const CustomDrawer({
    Key? key,
    required this.isDarkMode,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      child: Column(
        children: [
          // Fixed header
          Container(
            height: screenHeight * 0.292, 
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.headerGradient(isDarkMode),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF2D7A32),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ahmed Alsayegh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ahmed@email.com',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable drawer items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.health_and_safety, 'Health Records'),
                _buildDrawerItem(context, Icons.calendar_today, 'Appointments'),
                _buildDrawerItem(context, Icons.medication, 'Medications'),
                _buildDrawerItem(context, Icons.local_hospital, 'Emergency'),
                _buildDrawerItem(context, Icons.settings, 'Settings'),
                Divider(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[300],
                ),
                _buildDrawerItem(context, Icons.help_outline, 'Help & Support'),
                _buildDrawerItem(context, Icons.info_outline, 'About'),
                _buildDrawerItem(context, Icons.logout, 'Logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, [
    bool isActive = false,
  ]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? const Color(0xFF2D7A32).withOpacity(0.1) : null,
        border: isActive
            ? Border.all(color: const Color(0xFF2D7A32).withOpacity(0.3))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? const Color(0xFF00E676)
              : AppTheme.textSecondaryColor(isDarkMode),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? const Color(0xFF00E676)
                : AppTheme.textSecondaryColor(isDarkMode),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onItemTap(title);
        },
      ),
    );
  }
}
