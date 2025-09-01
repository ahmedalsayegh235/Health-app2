import 'package:flutter/material.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/app_theme.dart';
import '../../../widgets/activity_item.dart';

class ActivitySection extends StatelessWidget {
  final bool isDarkMode;

  const ActivitySection({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    // Take only the first 3 activities
    final activitiesToShow = activityProvider.activities.take(3).toList();

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
        if (activitiesToShow.isEmpty)
          Text(
            "No activities yet today.",
            style: TextStyle(color: AppTheme.textColor(isDarkMode)),
          )
        else
          ...activitiesToShow.map(
            (activity) => ActivityItem(
              icon: getIconData(activity['icon']),
              iconColor: Color(activity['iconColor']), // must be saved as int
              title: activity['title'],
              isDarkMode: isDarkMode,
              onTap: activity['onTap'],
            ),
          ),
      ],
    );
  }
}
