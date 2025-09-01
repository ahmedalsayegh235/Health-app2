import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';

class StatsCard extends StatelessWidget {
  final bool isDark;
  final int connectedDevices;
  final int totalDevices;

  const StatsCard({
    super.key,
    required this.isDark,
    required this.connectedDevices,
    required this.totalDevices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.headerGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.devices,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connected Devices',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$connectedDevices of $totalDevices',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                connectedDevices > 0 ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                connectedDevices > 0 ? 'Syncing' : 'Offline',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
