import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/Device_Tab_helpers.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final bool isDark;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSync;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isDark,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===== Device Header =====
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getDeviceColor(device.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getDeviceIcon(device.type),
                    color: getDeviceColor(device.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: getStatusColor(device.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getStatusText(device.status),
                            style: TextStyle(
                              fontSize: 14,
                              color: getStatusColor(device.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getBatteryIcon(device.batteryLevel),
                          color: getBatteryColor(device.batteryLevel),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${device.batteryLevel}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last sync: ${formatTime(device.lastSync)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== Features =====
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: device.features
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightgreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightgreen,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // ===== Action Buttons =====
            Row(
              children: [
                if (device.status == ConnectionStatus.disconnected) ...[
                  Expanded(
                    child: CustomButton(
                      onPressed: onConnect,
                      text: 'Connect',
                      height: 40,
                      gradientColors: [AppTheme.lightgreen, AppTheme.darkgreen],
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else if (device.status == ConnectionStatus.connected) ...[
                  Expanded(
                    child: CustomButton(
                      onPressed: onSync,
                      text: 'Sync Now',
                      height: 40,
                      gradientColors: [Colors.blue, Colors.lightBlue],
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      onPressed: onDisconnect,
                      text: 'Disconnect',
                      height: 40,
                      gradientColors: [
                        Colors.grey.withValues(alpha: 0.6),
                        Colors.grey.withValues(alpha: 0.4),
                      ],
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else if (device.status == ConnectionStatus.connecting) ...[
                  Expanded(
                    child: CustomButton(
                      onPressed: null,
                      text: 'Connecting...',
                      isLoading: true,
                      height: 40,
                      gradientColors: [Colors.orange, Colors.deepOrange],
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
