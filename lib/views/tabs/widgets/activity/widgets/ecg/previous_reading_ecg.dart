import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';
import 'package:health/views/tabs/widgets/activity/widgets/ecg/widgets/reading_card.dart';


class PreviousReadings extends StatelessWidget {
  final List<HealthReading> readings;
  final bool isDark;
  final VoidCallback? onViewAll;
  final void Function(HealthReading) onTap;

  const PreviousReadings({
    super.key,
    required this.readings,
    required this.isDark,
    this.onViewAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Text(
          'No previous readings',
          style: TextStyle(
            color: AppTheme.textSecondaryColor(isDark),
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Readings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor(isDark),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.lightgreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...readings.take(5).map(
          (reading) => ECGReadingCard(
            reading: reading,
            isDark: isDark,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
