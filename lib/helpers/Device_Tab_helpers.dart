import 'package:flutter/material.dart';
import 'app_theme.dart'; // wherever AppTheme is defined

// ===== Device Helpers =====
IconData getDeviceIcon(DeviceType type) {
  switch (type) {
    case DeviceType.smartwatch:
      return Icons.watch;
    case DeviceType.bloodPressure:
      return Icons.monitor_heart;
    case DeviceType.scale:
      return Icons.scale;
    case DeviceType.pulseOximeter:
      return Icons.air;
    case DeviceType.ecg:
      return Icons.show_chart;
  }
}

Color getDeviceColor(DeviceType type) {
  switch (type) {
    case DeviceType.smartwatch:
      return Colors.blue;
    case DeviceType.bloodPressure:
      return Colors.red;
    case DeviceType.scale:
      return Colors.purple;
    case DeviceType.pulseOximeter:
      return Colors.cyan;
    case DeviceType.ecg:
      return Colors.green;
  }
}

Color getStatusColor(ConnectionStatus status) {
  switch (status) {
    case ConnectionStatus.connected:
      return AppTheme.lightgreen;
    case ConnectionStatus.disconnected:
      return Colors.grey;
    case ConnectionStatus.connecting:
      return Colors.orange;
  }
}

String getStatusText(ConnectionStatus status) {
  switch (status) {
    case ConnectionStatus.connected:
      return 'Connected';
    case ConnectionStatus.disconnected:
      return 'Disconnected';
    case ConnectionStatus.connecting:
      return 'Connecting...';
  }
}

IconData getBatteryIcon(int level) {
  if (level > 80) return Icons.battery_full;
  if (level > 60) return Icons.battery_5_bar;
  if (level > 40) return Icons.battery_3_bar;
  if (level > 20) return Icons.battery_2_bar;
  return Icons.battery_1_bar;
}

Color getBatteryColor(int level) {
  if (level > 50) return AppTheme.lightgreen;
  if (level > 20) return Colors.orange;
  return Colors.red;
}

String formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

// ===== Data Models =====
enum DeviceType {
  smartwatch,
  bloodPressure,
  scale,
  pulseOximeter,
  ecg,
}

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}
