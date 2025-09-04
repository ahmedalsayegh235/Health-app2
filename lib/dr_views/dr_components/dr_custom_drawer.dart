import 'package:flutter/material.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:health/helpers/app_theme.dart';

class DrCustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final Function(String) onItemTap;

  const DrCustomDrawer({
    super.key,
    required this.isDarkMode,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
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
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        'assets/images/placeholderdog.png',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user != null && user.name != null && user.name!.isNotEmpty
                          ? user.name!.split(' ').first
                          : 'undefined user', // just incase firebase becomes dumb
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user != null &&
                              user.email != null &&
                              user.email!.isNotEmpty
                          ? '${user.email}'
                          : 'undefined user', // just incase firebase becomes dumb
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
                // _buildDrawerItem(
                //   context,
                //   Icons.health_and_safety,
                //   'Health Records',
                // ),
                _buildDrawerItem(context, Icons.calendar_today, 'Appointments'),
                _buildDrawerItem(context, Icons.chat_bubble, 'Chat'),
                // _buildDrawerItem(context, Icons.local_hospital, 'Emergency'),
                // _buildDrawerItem(context, Icons.settings, 'Settings'),
                Divider(
                  color: isDarkMode
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey[300],
                ),
                // _buildDrawerItem(context, Icons.help_outline, 'Help & Support'),
                // _buildDrawerItem(context, Icons.info_outline, 'About'),
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
        color: isActive ? const Color(0xFF2D7A32).withValues(alpha: .1) : null,
        border: isActive
            ? Border.all(color: const Color(0xFF2D7A32).withValues(alpha: .3))
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
