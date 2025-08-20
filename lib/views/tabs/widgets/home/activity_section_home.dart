import 'package:flutter/material.dart';
import '../../../../helpers/app_theme.dart';
import '../../../widgets/activity_item.dart';

class ActivitySection extends StatelessWidget {
  final bool isDarkMode;
  final List<Map<String, dynamic>> activities;

  const ActivitySection({
    super.key,
    required this.isDarkMode,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 20),
        ...activities.map(
          (activity) => ActivityItem(
            icon: activity['icon'],
            iconColor: activity['iconColor'],
            title: activity['title'],
            time: activity['time'],
            isDarkMode: isDarkMode,
            onTap: activity['onTap'],
          ),
        ),
      ],
    );
  }
}
