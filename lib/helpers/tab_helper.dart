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

// Heart Rate Classification based on Health Score Algorithm Report
Color getHeartStatusColor(double value) {
  if (value < 40) return Colors.red;
  if (value < 50) return Colors.orange;
  if (value >= 50 && value < 60) return Colors.blue;
  if (value >= 60 && value <= 80) return AppTheme.lightgreen;
  if (value > 80 && value <= 90) return Colors.orange;
  if (value > 90 && value <= 100) return Colors.deepOrange;
  if (value > 100 && value <= 110) return Colors.red;
  if (value > 110) return Colors.red.shade900;
  return AppTheme.lightgreen;
}

String getHeartStatusText(double value) {
  if (value < 40) return 'BRADYCARDIA';
  if (value < 50) return 'VERY LOW';
  if (value >= 50 && value < 60) return 'ATHLETIC/LOW';
  if (value >= 60 && value <= 80) return 'OPTIMAL';
  if (value > 80 && value <= 90) return 'SLIGHTLY ELEVATED';
  if (value > 90 && value <= 100) return 'ELEVATED';
  if (value > 100 && value <= 110) return 'HIGH';
  if (value > 110 && value <= 130) return 'VERY HIGH';
  if (value > 130) return 'DANGEROUS';
  return 'OPTIMAL';
}

String getHeartRateCategory(double value) {
  if (value < 40) return 'Bradycardia';
  if (value < 50) return 'Very Low';
  if (value >= 50 && value < 60) return 'Athletic/Low';
  if (value >= 60 && value <= 80) return 'Optimal';
  if (value > 80 && value <= 90) return 'Slightly Elevated';
  if (value > 90 && value <= 100) return 'Elevated';
  if (value > 100 && value <= 110) return 'High';
  if (value > 110 && value <= 130) return 'Very High';
  return 'Dangerous';
}

String getHeartRateRiskLevel(double value) {
  if (value < 40) return 'High';
  if (value < 50) return 'Moderate';
  if (value >= 50 && value < 60) return 'Low';
  if (value >= 60 && value <= 80) return 'Low';
  if (value > 80 && value <= 90) return 'Low-Moderate';
  if (value > 90 && value <= 100) return 'Moderate';
  if (value > 100 && value <= 110) return 'Moderate-High';
  if (value > 110 && value <= 130) return 'High';
  return 'Very High';
}

String getHeartRateAdvice(double value) {
  if (value < 40) {
    return 'Your heart rate is critically low (bradycardia). This may indicate a serious cardiac condition. Immediate medical evaluation is strongly recommended.';
  } else if (value < 50) {
    return 'Your heart rate is very low. Unless you are a trained athlete, this may require medical attention. Consult with a healthcare provider.';
  } else if (value >= 50 && value < 60) {
    return 'Your heart rate is in the athletic range. This is common for well-trained athletes and indicates good cardiovascular fitness.';
  } else if (value >= 60 && value <= 80) {
    return 'Your heart rate is optimal. This range is associated with improved cardiovascular outcomes and overall health. Keep up your healthy lifestyle!';
  } else if (value > 80 && value <= 90) {
    return 'Your heart rate is slightly elevated but still within normal range. Consider stress management, regular exercise, and adequate rest.';
  } else if (value > 90 && value <= 100) {
    return 'Your heart rate is elevated. Consider lifestyle modifications such as regular exercise, stress reduction, and maintaining a healthy weight.';
  } else if (value > 100 && value <= 110) {
    return 'Your heart rate is high. This may be due to stress, caffeine, or physical exertion. If persistent at rest, consult a healthcare provider.';
  } else if (value > 110 && value <= 130) {
    return 'Your heart rate is very high. This requires medical evaluation to rule out tachycardia or other cardiac conditions. Please contact a healthcare provider.';
  } else {
    return 'Your heart rate is dangerously high. Seek immediate medical attention. This may indicate a serious cardiac emergency.';
  }
}

bool requiresHeartRateMedicalAttention(double value) {
  return value < 50 || value > 110;
}

// SpO2 Classification based on Health Score Algorithm Report
Color getSPo2StatusColor(double value) {
  if (value < 85) return Colors.red.shade900;
  if (value >= 85 && value < 88) return Colors.red;
  if (value >= 88 && value < 92) return Colors.deepOrange;
  if (value >= 92 && value < 95) return Colors.orange;
  if (value == 95) return Colors.lightGreen;
  if (value >= 96 && value <= 97) return Colors.green;
  if (value >= 98 && value <= 99) return AppTheme.lightgreen;
  if (value == 100) return Colors.blue; // Possibly artifact
  return AppTheme.lightgreen;
}

String getSPo2StatusText(double value) {
  if (value < 85) return 'CRITICAL';
  if (value >= 85 && value < 88) return 'SEVERE HYPOXEMIA';
  if (value >= 88 && value < 92) return 'MODERATE HYPOXEMIA';
  if (value >= 92 && value < 95) return 'MILD HYPOXEMIA';
  if (value == 95) return 'LOW NORMAL';
  if (value >= 96 && value <= 97) return 'NORMAL';
  if (value >= 98 && value <= 99) return 'OPTIMAL';
  if (value == 100) return 'ARTIFACT?';
  return 'OPTIMAL';
}

String getSPo2Category(double value) {
  if (value < 85) return 'Critical Hypoxemia';
  if (value >= 85 && value < 88) return 'Severe Hypoxemia';
  if (value >= 88 && value < 92) return 'Moderate Hypoxemia';
  if (value >= 92 && value < 95) return 'Mild Hypoxemia';
  if (value == 95) return 'Low Normal';
  if (value >= 96 && value <= 97) return 'Normal';
  if (value >= 98 && value <= 99) return 'Optimal';
  return 'Possibly Artifact';
}

String getSPo2RiskLevel(double value) {
  if (value < 85) return 'Critical';
  if (value >= 85 && value < 88) return 'High';
  if (value >= 88 && value < 92) return 'Moderate-High';
  if (value >= 92 && value < 95) return 'Moderate';
  if (value == 95) return 'Low';
  if (value >= 96 && value <= 99) return 'Low';
  return 'Low';
}

String getSPo2Advice(double value) {
  if (value < 85) {
    return 'Your oxygen saturation is critically low. This is a medical emergency. Seek immediate medical attention. You may require supplemental oxygen.';
  } else if (value >= 85 && value < 88) {
    return 'Your oxygen saturation is severely low. This requires urgent medical intervention. Please go to the emergency room or call emergency services immediately.';
  } else if (value >= 88 && value < 92) {
    return 'Your oxygen saturation is moderately low. This requires prompt medical evaluation. Contact your healthcare provider immediately or visit urgent care.';
  } else if (value >= 92 && value < 95) {
    return 'Your oxygen saturation is mildly low. This may indicate respiratory issues or other health concerns. Schedule an appointment with your healthcare provider soon.';
  } else if (value == 95) {
    return 'Your oxygen saturation is at the lower end of normal. If you experience any symptoms like shortness of breath, consult a healthcare provider.';
  } else if (value >= 96 && value <= 97) {
    return 'Your oxygen saturation is normal. Continue monitoring your health and maintain a healthy lifestyle.';
  } else if (value >= 98 && value <= 99) {
    return 'Your oxygen saturation is optimal. This indicates healthy respiratory function. Keep up your good health practices!';
  } else {
    return 'Reading of 100% may sometimes indicate sensor artifacts. If this reading persists or you have concerns, retest or consult a healthcare provider.';
  }
}

bool requiresSPo2MedicalAttention(double value) {
  return value < 95;
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

// ECG-Derived Heart Rate Classification (same as Heart Rate but for ECG readings)
// ECG provides more accurate measurement compared to PPG-based readings
Color getECGHeartRateStatusColor(double value) {
  return getHeartStatusColor(value); // Uses same classification as regular heart rate
}

String getECGHeartRateStatusText(double value) {
  return getHeartStatusText(value);
}

String getECGHeartRateCategory(double value) {
  return getHeartRateCategory(value);
}

String getECGHeartRateRiskLevel(double value) {
  return getHeartRateRiskLevel(value);
}

String getECGHeartRateAdvice(double value) {
  // ECG-specific advice with mention of rhythm analysis
  if (value < 40) {
    return 'Your ECG-derived heart rate is critically low (bradycardia). This may indicate a serious cardiac condition. Immediate medical evaluation is strongly recommended. The ECG rhythm should be reviewed by a healthcare provider.';
  } else if (value < 50) {
    return 'Your ECG-derived heart rate is very low. Unless you are a trained athlete, this may require medical attention. Consult with a healthcare provider for ECG interpretation.';
  } else if (value >= 50 && value < 60) {
    return 'Your ECG-derived heart rate is in the athletic range. This is common for well-trained athletes and indicates good cardiovascular fitness. The ECG rhythm appears regular.';
  } else if (value >= 60 && value <= 80) {
    return 'Your ECG-derived heart rate is optimal. This range is associated with improved cardiovascular outcomes and overall health. The ECG shows good cardiac rhythm. Keep up your healthy lifestyle!';
  } else if (value > 80 && value <= 90) {
    return 'Your ECG-derived heart rate is slightly elevated but still within normal range. Consider stress management, regular exercise, and adequate rest. ECG rhythm analysis can provide additional insights.';
  } else if (value > 90 && value <= 100) {
    return 'Your ECG-derived heart rate is elevated. Consider lifestyle modifications such as regular exercise, stress reduction, and maintaining a healthy weight. Review your ECG with a healthcare provider if this persists.';
  } else if (value > 100 && value <= 110) {
    return 'Your ECG-derived heart rate is high. This may be due to stress, caffeine, or physical exertion. If persistent at rest, consult a healthcare provider for ECG analysis.';
  } else if (value > 110 && value <= 130) {
    return 'Your ECG-derived heart rate is very high. This requires medical evaluation to rule out tachycardia or other cardiac conditions. Please contact a healthcare provider for ECG interpretation.';
  } else {
    return 'Your ECG-derived heart rate is dangerously high. Seek immediate medical attention. This may indicate a serious cardiac emergency. Your ECG rhythm requires urgent professional evaluation.';
  }
}

bool requiresECGMedicalAttention(double value) {
  return value < 50 || value > 110;
}

// Helper function for rhythm classification
String getECGRhythmAdvice(String rhythm) {
  switch (rhythm.toLowerCase()) {
    case 'normal sinus rhythm':
      return 'Your heart rhythm is normal. This is the healthy rhythm pattern expected in a resting state.';
    case 'bradycardia':
      return 'Your heart is beating slower than normal. If you\'re not an athlete, consult a healthcare provider.';
    case 'tachycardia':
      return 'Your heart is beating faster than normal. Consider stress management and consult a healthcare provider if persistent.';
    case 'irregular rhythm':
      return 'Your heart rhythm appears irregular. This may indicate arrhythmia and requires medical evaluation.';
    case 'poor signal quality':
      return 'The ECG signal quality was insufficient for accurate analysis. Please retake the measurement ensuring good sensor contact.';
    default:
      return 'ECG rhythm analysis is pending. Consult a healthcare provider for detailed interpretation.';
  }
}

bool requiresECGRhythmMedicalAttention(String rhythm) {
  final concerningRhythms = ['bradycardia', 'tachycardia', 'irregular rhythm'];
  return concerningRhythms.contains(rhythm.toLowerCase());
}

// helper function
IconData getIconData(String iconName) {
  print(iconName);
  switch (iconName.trim().toLowerCase()) {
    case 'heart':
      return Icons.favorite;
    case 'spo2':
      return Icons.air;
    case 'ecg':
      return Icons.favorite_border;
    case 'scale':
      return Icons.monitor_weight_rounded;
    case 'bloodtype':
      return Icons.bloodtype;
    default:
      return Icons.help; // fallback
  }
}
