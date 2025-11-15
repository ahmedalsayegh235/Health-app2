import 'package:flutter/material.dart';
import 'package:health/controllers/blood_sugar_controller.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/app_theme.dart';
import '../../../widgets/metric_card.dart';
import '../../../../controllers/sensor_provider.dart';
import '../../../../models/Reading.dart';
import '../../../../controllers/BMI_controller.dart';

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

        Row(
          children: [
            // Heart Rate (last + previous)
            Expanded(
              child: StreamBuilder<List<HealthReading>>(
                stream: Provider.of<SensorProvider>(
                  context,
                  listen: false,
                ).heartRateStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildLoadingCard(
                      icon: Icons.favorite,
                      color: Colors.red,
                      title: "Heart Rate",
                      unit: "bpm",
                    );
                  }

                  final readings = snapshot.data!;
                  final latest = readings.first.value.toInt();
                  final previous = readings.length > 1
                      ? readings[1].value.toInt()
                      : 0;

                  return MetricCard(
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    title: "Heart Rate",
                    value: latest.toDouble(),
                    previousValue: previous.toDouble(),
                    unit: "bpm",
                    isDarkMode: isDarkMode,
                    animationController: AnimationController(
                      vsync: vsync,
                      duration: const Duration(milliseconds: 150),
                    ),
                    onTap: () {},
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // SpO₂ (last + previous)
            Expanded(
              child: StreamBuilder<List<HealthReading>>(
                stream: Provider.of<SensorProvider>(
                  context,
                  listen: false,
                ).spo2Stream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildLoadingCard(
                      icon: Icons.water_drop_outlined,
                      color: Colors.blue,
                      title: "SpO₂",
                      unit: "%",
                    );
                  }

                  final readings = snapshot.data!;
                  final latest = readings.first.value.toInt();
                  final previous = readings.length > 1
                      ? readings[1].value.toInt()
                      : 0;

                  return MetricCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: Colors.blue,
                    title: "SpO₂",
                    value: latest.toDouble(),
                    previousValue: previous.toDouble(),
                    unit: "%",
                    isDarkMode: isDarkMode,
                    animationController: AnimationController(
                      vsync: vsync,
                      duration: const Duration(milliseconds: 150),
                    ),
                    onTap: () {},
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            //bmi health 
          Expanded(
            child: StreamBuilder<List<HealthReading>>(
              stream: Provider.of<BmiController>(context, listen: false).bmiStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildLoadingCard(
                    icon: Icons.monitor_weight_outlined,
                    color: Colors.green,
                    title: "BMI",
                    unit: "kg/m²",
                  );
                }

                final readings = snapshot.data!;
                final latest = readings.first.value;
                final previous = readings.length > 1 ? readings[1].value : latest;

                final category = BmiController.getBmiCategory(latest);
                final color = BmiController.getBmiCategoryColor(latest);

                return MetricCard(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: color,
                  title: "BMI",
                  value: latest,
                  previousValue: previous,
                  unit: "kg/m²",
                  isDarkMode: isDarkMode,
                  animationController: AnimationController(
                    vsync: vsync,
                    duration: const Duration(milliseconds: 150),
                  ),
                  onTap: () {
                    // Optional: show more BMI details or chart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('BMI: ${latest.toStringAsFixed(1)} - $category')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: StreamBuilder<List<HealthReading>>(
                stream: Provider.of<SensorProvider>(
                  context,
                  listen: false,
                ).ecgStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildLoadingCard(
                      icon: Icons.monitor_heart,
                      color: Colors.purple,
                      title: "ECG",
                      unit: "BPM",
                    );
                  }

                  final readings = snapshot.data!;
                  final latest = readings.first.value
                      .toDouble(); // latest reading
                  final previous = readings.length > 1
                      ? readings[1].value.toDouble()
                      : 0.0; // previous reading

                  return MetricCard(
                    icon: Icons.monitor_heart,
                    iconColor: Colors.purple,
                    title: "ECG",
                    value: latest,
                    previousValue: previous,
                    unit: "BPM",
                    isDarkMode: isDarkMode,
                    animationController: AnimationController(
                      vsync: vsync,
                      duration: const Duration(milliseconds: 150),
                    ),
                    onTap: () {
                     // nav to HR tab
                    },
                  );
                },
              ),
            ),

            const SizedBox(width: 12),
Expanded(
  child: StreamBuilder<List<HealthReading>>(
    stream: Provider.of<BloodSugarController>(context, listen: false)
        .bloodSugarStream(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _buildLoadingCard(
          icon: Icons.bloodtype,
          color: Colors.orange,
          title: "Blood Sugar",
          unit: "mg/dL",
        );
      }

      final readings = snapshot.data!;
      final latestReading = readings.first;
      final latest = latestReading.value;

      final previous = readings.length > 1
          ? readings[1].value
          : latest;

    final readingType =
    (latestReading.metadata != null
        ? latestReading.metadata!['readingType']
        : null) ??
    'random';


      final category = BloodSugarController.getBloodSugarCategory(
        latest,
        readingType,
      );

      final color = BloodSugarController.getBloodSugarCategoryColor(
        latest,
        readingType,
      );

      return MetricCard(
        icon: Icons.bloodtype,
        iconColor: color,
        title: "Blood Sugar",
        value: latest,
        previousValue: previous,
        unit: "mg/dL",
        isDarkMode: isDarkMode,
        animationController: AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 150),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Blood Sugar: ${latest.toStringAsFixed(1)} mg/dL - $category ($readingType)',
              ),
            ),
          );
        },
      );
    },
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

  /// just a placeholder card while waiting for Firestore data
  Widget _buildLoadingCard({
    required IconData icon,
    required Color color,
    required String title,
    required String unit,
  }) {
    return MetricCard(
      icon: icon,
      iconColor: color,
      title: title,
      value: 0,
      previousValue: 0,
      unit: unit,
      isDarkMode: isDarkMode,
      animationController: AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 150),
      ),
      onTap: () {},
    );
  }
}
