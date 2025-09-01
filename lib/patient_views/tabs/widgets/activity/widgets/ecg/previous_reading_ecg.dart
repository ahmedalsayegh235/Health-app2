import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';

class EcgReadingCard extends StatelessWidget {
  final HealthReading reading;
  final bool isDark;
  final void Function(HealthReading) onTap;
  final String Function(DateTime) formatTime;

  const EcgReadingCard({
    super.key,
    required this.reading,
    required this.isDark,
    required this.onTap,
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
            // ECG Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.monitor_heart, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 16),

            // ECG Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ECG Recording",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading.note.isNotEmpty ? reading.note : "Tap to view details",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Time & Arrow
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
