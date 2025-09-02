// ecg_tab_helpers.dart
import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';

/// Returns a color based on the ECG reading value
Color getStatusColor(double value) {
  if (value < 0.5) return Colors.orange;
  if (value > 1.2) return Colors.orange;
  return AppTheme.lightgreen;
}

/// Returns a status text based on the ECG reading value
String getStatusText(double value) {
  if (value < 0.5) return 'LOW';
  if (value > 1.2) return 'HIGH';
  return 'NORMAL';
}

/// Formats a DateTime into a human-readable difference
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

 Color getHeartStatusColor(double value) {
    if (value < 60) return Colors.blue;
    if (value > 100) return Colors.orange;
    return AppTheme.lightgreen;
  }

  String getHeartStatusText(double value) {
    if (value < 60) return 'LOW';
    if (value > 100) return 'HIGH';
    return 'NORMAL';
  }

  Color getSPo2StatusColor(double value) {
    if (value < 90) return Colors.red;
    if (value < 95) return Colors.orange;
    return AppTheme.lightgreen;
  }

  String getSPo2StatusText(double value) {
    if (value < 90) return 'LOW';
    if (value < 95) return 'FAIR';
    return 'NORMAL';
  }


 Color getQualityColor(double quality) {
    if (quality >= 0.8) return Colors.green;
    if (quality >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String getRhythmShort(String rhythm) {
    switch (rhythm.toLowerCase()) {
      case 'normal sinus rhythm':
        return 'Normal';
      case 'bradycardia':
        return 'Slow';
      case 'tachycardia':
        return 'Fast';
      default:
        return rhythm.length > 10 ? '${rhythm.substring(0, 10)}...' : rhythm;
    }
  }


// helper function
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'heart':
      return Icons.favorite;
    case 'spo2':
      return Icons.air;
    case 'ecg':
      return Icons.favorite_border;
    case 'home':
      return Icons.home;
    // add more as needed
    default:
      return Icons.help; // fallback
  }
}




  
