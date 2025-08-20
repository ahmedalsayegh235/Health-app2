import 'package:flutter/material.dart';
import '../../../../helpers/app_theme.dart';
import '../../../widgets/metric_card.dart';

class HealthMetricsSection extends StatelessWidget {
  final TickerProvider vsync; 
  final bool isDarkMode;

  const HealthMetricsSection({
    Key? key,
    required this.vsync,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 20),

        // First Row
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.favorite,
                iconColor: Colors.red,
                title: "Heart Rate",
                value: 78,
                previousValue: 50,
                unit: "bpm",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.water_drop_outlined,
                iconColor: Colors.blue,
                title: "SpO₂",
                value: 98,
                previousValue: 97,
                unit: "%",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.monitor_weight_outlined,
                iconColor: Colors.green,
                title: "Weight",
                value: 70,
                previousValue: 72,
                unit: "kg",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Second Row
        Row(
          children: [
            Expanded(
              child: MetricCard(
                icon: Icons.show_chart,
                iconColor: Colors.purple,
                title: "ECG",
                value: 85,
                previousValue: 80,
                unit: "bpm",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.bloodtype,
                iconColor: Colors.orange,
                title: "Blood Sugar",
                value: 110,
                previousValue: 105,
                unit: "mg/dL",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                icon: Icons.directions_walk,
                iconColor: Colors.teal,
                title: "Steps/Day",
                value: 7500,
                previousValue: 6800,
                unit: "steps",
                isDarkMode: isDarkMode,
                animationController: AnimationController(
                  vsync: vsync,
                  duration: const Duration(milliseconds: 150),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
