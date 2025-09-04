import 'package:flutter/material.dart';
import '../../helpers/app_theme.dart';

class DrQuickActions extends StatelessWidget {
  final bool isDarkMode;

  const DrQuickActions({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor(isDarkMode),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
           padding: EdgeInsets.only(top:20), // remove default padding
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _QuickActionCard(
              title: 'View Appointments',
              subtitle: 'Manage schedule',
              icon: Icons.calendar_view_day,
              color: AppTheme.infoColor,
              isDarkMode: isDarkMode,
              onTap: () {
                // Navigate to appointments tab
              },
            ),
            _QuickActionCard(
              title: 'Patient Messages',
              subtitle: 'Check chats',
              icon: Icons.chat_bubble_outline,
              color: AppTheme.successColor,
              isDarkMode: isDarkMode,
              onTap: () {
                // Navigate to chat tab
              },
            ),
            _QuickActionCard(
              title: 'Add Availability',
              subtitle: 'Set new slots',
              icon: Icons.add_circle_outline,
              color: AppTheme.warningColor,
              isDarkMode: isDarkMode,
              onTap: () {
                _showAddAvailabilityDialog(context);
              },
            ),
            _QuickActionCard(
              title: 'Patient Records',
              subtitle: 'View history',
              icon: Icons.folder_outlined,
              color: AppTheme.lightgreen,
              isDarkMode: isDarkMode,
              onTap: () {
                // Navigate to patient records
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showAddAvailabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor(isDarkMode),
        title: Text(
          'Add Availability',
          style: TextStyle(color: AppTheme.textColor(isDarkMode)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This feature will allow you to add new appointment slots.',
              style: TextStyle(color: AppTheme.textSecondaryColor(isDarkMode)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondaryColor(isDarkMode)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement add availability logic
            },
            style: AppTheme.primaryButtonStyle(isDarkMode),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration(isDarkMode),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondaryColor(isDarkMode),
                    size: 12,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(isDarkMode),
                    ),
                  ),
                  const SizedBox(height:1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor(isDarkMode),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}