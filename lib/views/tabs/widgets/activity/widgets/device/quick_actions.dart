import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/controllers/device_controller.dart';
import 'package:health/helpers/app_theme.dart';

class QuickActions extends StatelessWidget {
  final DeviceController controller;

  const QuickActions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            onPressed: () {
              controller.scanDevices(context);
            },
            text: 'Scan Devices',
            height: 50,
            gradientColors: [AppTheme.lightgreen, AppTheme.darkgreen],
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            onPressed: () {
              controller.syncAllDevices(context);
            },
            text: 'Sync All',
            height: 50,
            gradientColors: [
              Colors.blue.withValues(alpha: .8),
              Colors.lightBlue.withValues(alpha: .6),
            ],
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
