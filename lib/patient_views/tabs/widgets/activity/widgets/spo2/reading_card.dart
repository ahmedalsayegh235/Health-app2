import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';

class ReadingCard extends StatelessWidget {
  final HealthReading reading;
  final bool isDark;
  final Function(HealthReading) onTap;
  final Color Function(double) getSPo2StatusColor;
  final String Function(double) getSPo2StatusText;
  final String Function(DateTime) formatTime;

  const ReadingCard({
    super.key,
    required this.reading,
    required this.isDark,
    required this.onTap,
    required this.getSPo2StatusColor,
    required this.getSPo2StatusText,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onTap(reading),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.air, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${reading.value.toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(isDark),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: getSPo2StatusColor(reading.value).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getSPo2StatusText(reading.value),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: getSPo2StatusColor(reading.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading.note,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(reading.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textSecondaryColor(isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
