import 'package:flutter/material.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/controllers/blood_sugar_controller.dart';

/// these are the referenced equations we used in calculating the health score
/// References:
/// - WHO (2000) BMI Classification
/// - American Heart Association (2024) Heart Rate Guidelines
/// - WHO (2011) SpO2 Pulse Oximetry Training Manual
/// - American Diabetes Association (2025) Blood Glucose Standards
/// - Seeman et al. (1997) Allostatic Load Methodology
class HealthScoreProvider extends ChangeNotifier {
  final BmiController bmiController;
  final SensorProvider sensorProvider;
  final BloodSugarController? bloodSugarController;

  int _healthScore = 0;
  DateTime? _lastUpdated;
  
  /// Individual component scores (0-100 each)
  Map<String, int> _componentScores = {
    'bmi': 0,
    'heartRate': 0,
    'spo2': 0,
    'bloodSugar': 0,
    'ecgHeartRate': 0,
  };

  /// this is the referenced weights used in the research
  static const Map<String, double> _componentWeights = {
    'bmi': 0.20,           // Metabolic health indicator (WHO, 2000)
    'heartRate': 0.20,     // Cardiovascular function (AHA, 2024)
    'spo2': 0.25,          // Critical respiratory marker (WHO, 2011)
    'bloodSugar': 0.20,    // Metabolic/diabetes risk (ADA, 2025)
    'ecgHeartRate': 0.15,  // Cardiac rhythm accuracy bonus
  };

  // Track last reading IDs to detect changes
  String? _lastBmiId;
  String? _lastHrId;
  String? _lastSpo2Id;
  String? _lastBloodSugarId;
  String? _lastEcgId;

  int get healthScore => _healthScore;
  DateTime? get lastUpdated => _lastUpdated;
  Map<String, int> get componentScores => Map.unmodifiable(_componentScores);
  Map<String, double> get componentWeights => Map.unmodifiable(_componentWeights);

  HealthScoreProvider({
    required this.bmiController,
    required this.sensorProvider,
    this.bloodSugarController,
  }) {
    // Listen to changes in all providers
    bmiController.addListener(_onDataChanged);
    sensorProvider.addListener(_onDataChanged);
    bloodSugarController?.addListener(_onDataChanged);
    
    // Initial calculation after a short delay to allow data loading
    Future.delayed(const Duration(milliseconds: 500), _onDataChanged);
  }

  /// Check if any data has changed and recalculate if needed
  void _onDataChanged() {
    bool hasChanged = false;

    // Check BMI reading
    final currentBmiId = bmiController.latestBmi?.id;
    if (currentBmiId != _lastBmiId) {
      _lastBmiId = currentBmiId;
      hasChanged = true;
    }

    // Check Heart Rate reading
    final currentHrId = sensorProvider.lastHeartRate?.id;
    if (currentHrId != _lastHrId) {
      _lastHrId = currentHrId;
      hasChanged = true;
    }

    // Check SpO2 reading
    final currentSpo2Id = sensorProvider.lastSpo2?.id;
    if (currentSpo2Id != _lastSpo2Id) {
      _lastSpo2Id = currentSpo2Id;
      hasChanged = true;
    }

    // Check Blood Sugar reading
    final currentBloodSugarId = bloodSugarController?.latestBloodSugar?.id;
    if (currentBloodSugarId != _lastBloodSugarId) {
      _lastBloodSugarId = currentBloodSugarId;
      hasChanged = true;
    }

    // Check ECG reading
    final currentEcgId = sensorProvider.lastEcgReading?.id;
    if (currentEcgId != _lastEcgId) {
      _lastEcgId = currentEcgId;
      hasChanged = true;
    }

    if (hasChanged) {
      _calculateHealthScore();
    }
  }

  /// Calculate the comprehensive health score using weighted average
  void _calculateHealthScore() {
    // Calculate individual component scores
    final bmiScore = _calculateBmiScore();
    final heartRateScore = _calculateHeartRateScore();
    final spo2Score = _calculateSpo2Score();
    final bloodSugarScore = _calculateBloodSugarScore();
    final ecgHeartRateScore = _calculateEcgHeartRateScore();

    _componentScores = {
      'bmi': bmiScore,
      'heartRate': heartRateScore,
      'spo2': spo2Score,
      'bloodSugar': bloodSugarScore,
      'ecgHeartRate': ecgHeartRateScore,
    };

    // Calculate weighted average for available scores
    double totalWeightedScore = 0;
    double totalWeight = 0;

    if (bmiScore > 0) {
      totalWeightedScore += bmiScore * _componentWeights['bmi']!;
      totalWeight += _componentWeights['bmi']!;
    }
    if (heartRateScore > 0) {
      totalWeightedScore += heartRateScore * _componentWeights['heartRate']!;
      totalWeight += _componentWeights['heartRate']!;
    }
    if (spo2Score > 0) {
      totalWeightedScore += spo2Score * _componentWeights['spo2']!;
      totalWeight += _componentWeights['spo2']!;
    }
    if (bloodSugarScore > 0) {
      totalWeightedScore += bloodSugarScore * _componentWeights['bloodSugar']!;
      totalWeight += _componentWeights['bloodSugar']!;
    }
    if (ecgHeartRateScore > 0) {
      totalWeightedScore += ecgHeartRateScore * _componentWeights['ecgHeartRate']!;
      totalWeight += _componentWeights['ecgHeartRate']!;
    }

    // Calculate final weighted average
    if (totalWeight > 0) {
      _healthScore = (totalWeightedScore / totalWeight).round().clamp(0, 100);
      _lastUpdated = DateTime.now();
    } else {
      _healthScore = 0;
      _lastUpdated = null;
    }

    notifyListeners();
  }

  /// Calculate BMI Score (0-100)
  /// Reference: WHO (2000) Obesity Classification
  /// Optimal BMI range: 18.5-24.9 kg/m²
  int _calculateBmiScore() {
    final latestBmi = bmiController.latestBmi;
    if (latestBmi == null) return 0;

    final bmi = latestBmi.value;

    // WHO Classification-based scoring
    if (bmi >= 18.5 && bmi < 25) {
      // Optimal range - maximum score
      // Peak score at BMI 21.5 (WHO recommended median)
      final deviation = (bmi - 21.75).abs();
      return (100 - deviation * 1.5).round().clamp(95, 100);
    } else if (bmi >= 25 && bmi < 27) {
      // Overweight Grade I: 85-95 points
      return (95 - ((bmi - 25) * 5)).round().clamp(85, 95);
    } else if (bmi >= 17 && bmi < 18.5) {
      // Mild underweight: 80-95 points
      return (80 + ((bmi - 17) * 10)).round().clamp(80, 95);
    } else if (bmi >= 27 && bmi < 30) {
      // Overweight Grade II: 70-85 points
      return (85 - ((bmi - 27) * 5)).round().clamp(70, 85);
    } else if (bmi >= 30 && bmi < 35) {
      // Obese Class I: 50-70 points
      return (70 - ((bmi - 30) * 4)).round().clamp(50, 70);
    } else if (bmi >= 15 && bmi < 17) {
      // Moderate underweight: 60-80 points
      return (60 + ((bmi - 15) * 10)).round().clamp(60, 80);
    } else if (bmi >= 35 && bmi < 40) {
      // Obese Class II: 30-50 points
      return (50 - ((bmi - 35) * 4)).round().clamp(30, 50);
    } else if (bmi >= 40) {
      // Obese Class III: 10-30 points
      return (30 - ((bmi - 40) * 2)).round().clamp(10, 30);
    } else if (bmi < 15) {
      // Severe underweight: 20-60 points
      return (20 + ((bmi - 10) * 8)).round().clamp(20, 60);
    }
    
    return 50; // Default fallback
  }

  /// Calculate Heart Rate Score (0-100)
  /// Reference: American Heart Association (2024)
  /// Normal resting HR: 60-100 bpm, optimal: 60-80 bpm
  int _calculateHeartRateScore() {
    final latestHR = sensorProvider.lastHeartRate;
    if (latestHR == null) return 0;

    final hr = latestHR.value;

    // AHA-based scoring
    if (hr >= 60 && hr <= 80) {
      // Optimal resting heart rate - maximum score
      return 100;
    } else if (hr > 80 && hr <= 90) {
      // Slightly elevated: 85-95 points
      return (95 - ((hr - 80) * 1)).round().clamp(85, 95);
    } else if (hr >= 50 && hr < 60) {
      // Athletic/low heart rate: 90-100 points
      return (90 + ((hr - 50) * 1)).round().clamp(90, 100);
    } else if (hr > 90 && hr <= 100) {
      // Elevated: 70-85 points
      return (85 - ((hr - 90) * 1.5)).round().clamp(70, 85);
    } else if (hr > 100 && hr <= 110) {
      // High: 55-70 points
      return (70 - ((hr - 100) * 1.5)).round().clamp(55, 70);
    } else if (hr >= 40 && hr < 50) {
      // Very low (may be athletic): 70-90 points
      return (70 + ((hr - 40) * 2)).round().clamp(70, 90);
    } else if (hr > 110 && hr <= 130) {
      // Very high: 30-55 points
      return (55 - ((hr - 110) * 1.25)).round().clamp(30, 55);
    } else if (hr > 130) {
      // Dangerous high: 10-30 points
      return (30 - ((hr - 130) * 0.5)).round().clamp(10, 30);
    } else if (hr < 40) {
      // Dangerously low bradycardia: 20-70 points
      return (20 + ((hr - 30) * 5)).round().clamp(20, 70);
    }
    
    return 50; // Default fallback
  }

  /// Calculate SpO2 Score (0-100)
  /// Reference: WHO (2011) Pulse Oximetry Training Manual
  /// Normal SpO2: 95-100%, hypoxemia: <90%
  int _calculateSpo2Score() {
    final latestSpo2 = sensorProvider.lastSpo2;
    if (latestSpo2 == null) return 0;

    final spo2 = latestSpo2.value;

    // WHO-based scoring
    if (spo2 >= 95 && spo2 <= 100) {
      // Normal oxygen saturation
      if (spo2 >= 98 && spo2 <= 99) {
        // Optimal range
        return 100;
      } else if (spo2 == 100) {
        // 100% may indicate sensor artifact
        return 98;
      } else if (spo2 >= 96 && spo2 <= 97) {
        return (95 + ((spo2 - 96) * 2.5)).round().clamp(95, 98);
      } else {
        // 95%
        return 95;
      }
    } else if (spo2 >= 92 && spo2 < 95) {
      // Mild hypoxemia: 75-95 points
      return (75 + ((spo2 - 92) * 6.67)).round().clamp(75, 95);
    } else if (spo2 >= 88 && spo2 < 92) {
      // Moderate hypoxemia: 50-75 points
      return (50 + ((spo2 - 88) * 6.25)).round().clamp(50, 75);
    } else if (spo2 >= 85 && spo2 < 88) {
      // Severe hypoxemia: 30-50 points
      return (30 + ((spo2 - 85) * 6.67)).round().clamp(30, 50);
    } else if (spo2 < 85) {
      // Critical hypoxemia: 10-30 points
      return (10 + ((spo2 - 80) * 4)).round().clamp(10, 30);
    }
    
    return 0;
  }

  /// Calculate Blood Sugar Score (0-100)
  /// Reference: American Diabetes Association (2025) Standards of Care
  /// Normal fasting: 70-99 mg/dL, prediabetes: 100-125, diabetes: ≥126
  int _calculateBloodSugarScore() {
    final latestBloodSugar = bloodSugarController?.latestBloodSugar;
    if (latestBloodSugar == null) return 0;

    final glucose = latestBloodSugar.value;
    final readingType = latestBloodSugar.metadata?['readingType'] as String? ?? 'fasting';

    if (readingType == 'fasting') {
      return _calculateFastingGlucoseScore(glucose);
    } else if (readingType == 'post_meal') {
      return _calculatePostMealGlucoseScore(glucose);
    } else {
      return _calculateRandomGlucoseScore(glucose);
    }
  }

  /// Fasting glucose scoring (ADA thresholds)
  int _calculateFastingGlucoseScore(double glucose) {
    if (glucose >= 70 && glucose < 100) {
      // Normal fasting glucose: 95-100 points
      // Optimal at 85 mg/dL based on cardiovascular research
      final deviation = (glucose - 85).abs();
      return (100 - deviation * 0.33).round().clamp(95, 100);
    } else if (glucose >= 100 && glucose < 110) {
      // Prediabetes (low): 80-95 points
      return (95 - ((glucose - 100) * 1.5)).round().clamp(80, 95);
    } else if (glucose >= 110 && glucose < 126) {
      // Prediabetes (high): 60-80 points
      return (80 - ((glucose - 110) * 1.25)).round().clamp(60, 80);
    } else if (glucose >= 126 && glucose < 150) {
      // Diabetes (mild): 40-60 points
      return (60 - ((glucose - 126) * 0.83)).round().clamp(40, 60);
    } else if (glucose >= 150 && glucose < 200) {
      // Diabetes (moderate): 20-40 points
      return (40 - ((glucose - 150) * 0.4)).round().clamp(20, 40);
    } else if (glucose >= 200) {
      // Diabetes (severe): 5-20 points
      return (20 - ((glucose - 200) * 0.15)).round().clamp(5, 20);
    } else if (glucose < 70) {
      // Hypoglycemia: 60-90 points (depending on severity)
      if (glucose >= 54) {
        return (90 - ((70 - glucose) * 1.875)).round().clamp(60, 90);
      } else {
        // Severe hypoglycemia
        return (60 - ((54 - glucose) * 2)).round().clamp(30, 60);
      }
    }
    
    return 50;
  }

  /// Post-meal glucose scoring (2-hour post-prandial)
  int _calculatePostMealGlucoseScore(double glucose) {
    if (glucose < 70) {
      // Hypoglycemia
      return (70 - ((70 - glucose) * 1.5)).round().clamp(40, 70);
    } else if (glucose < 140) {
      // Normal post-meal: 90-100 points
      return (100 - ((glucose - 70) * 0.14)).round().clamp(90, 100);
    } else if (glucose < 180) {
      // Elevated: 70-90 points
      return (90 - ((glucose - 140) * 0.5)).round().clamp(70, 90);
    } else if (glucose < 200) {
      // High: 50-70 points
      return (70 - ((glucose - 180) * 1)).round().clamp(50, 70);
    } else {
      // Very high: 20-50 points
      return (50 - ((glucose - 200) * 0.3)).round().clamp(20, 50);
    }
  }

  /// Random glucose scoring
  int _calculateRandomGlucoseScore(double glucose) {
    if (glucose < 70) {
      return (80 - ((70 - glucose) * 2)).round().clamp(40, 80);
    } else if (glucose < 140) {
      return (100 - ((glucose - 70) * 0.14)).round().clamp(90, 100);
    } else if (glucose < 200) {
      return (90 - ((glucose - 140) * 0.67)).round().clamp(50, 90);
    } else {
      return (50 - ((glucose - 200) * 0.2)).round().clamp(15, 50);
    }
  }

  /// Calculate ECG-derived Heart Rate Score (0-100)
  /// Uses same methodology as standard HR but from ECG readings
  /// May include rhythm analysis penalty
  int _calculateEcgHeartRateScore() {
    final latestEcg = sensorProvider.lastEcgReading;
    if (latestEcg == null) return 0;

    final ecgHr = latestEcg.value; // Heart rate from ECG
    final rhythm = latestEcg.metadata?['rhythm'] as String? ?? 'Unknown';
    
    if (ecgHr <= 0) return 0;

    // Base score same as heart rate calculation
    int baseScore;
    
    if (ecgHr >= 60 && ecgHr <= 80) {
      baseScore = 100;
    } else if (ecgHr > 80 && ecgHr <= 90) {
      baseScore = (95 - ((ecgHr - 80) * 1)).round().clamp(85, 95);
    } else if (ecgHr >= 50 && ecgHr < 60) {
      baseScore = (90 + ((ecgHr - 50) * 1)).round().clamp(90, 100);
    } else if (ecgHr > 90 && ecgHr <= 100) {
      baseScore = (85 - ((ecgHr - 90) * 1.5)).round().clamp(70, 85);
    } else if (ecgHr > 100 && ecgHr <= 110) {
      baseScore = (70 - ((ecgHr - 100) * 1.5)).round().clamp(55, 70);
    } else if (ecgHr >= 40 && ecgHr < 50) {
      baseScore = (70 + ((ecgHr - 40) * 2)).round().clamp(70, 90);
    } else if (ecgHr > 110) {
      baseScore = (55 - ((ecgHr - 110) * 0.5)).round().clamp(25, 55);
    } else {
      baseScore = (40 + (ecgHr - 30) * 3).round().clamp(30, 70);
    }

    // Apply rhythm penalty if abnormal
    if (rhythm == 'Irregular Rhythm') {
      baseScore = (baseScore * 0.9).round();
    } else if (rhythm == 'Poor Signal Quality') {
      // Don't apply penalty for poor signal, just less confidence
      baseScore = (baseScore * 0.95).round();
    } else if (rhythm == 'Tachycardia' || rhythm == 'Bradycardia') {
      baseScore = (baseScore * 0.92).round();
    }

    return baseScore.clamp(0, 100);
  }

  /// Get health status text based on score
  /// Classification based on clinical risk stratification
  String getHealthStatus() {
    if (_healthScore >= 90) return 'Excellent';
    if (_healthScore >= 75) return 'Good';
    if (_healthScore >= 60) return 'Fair';
    if (_healthScore >= 40) return 'Poor';
    return 'Critical';
  }

  /// Get status color for UI display
  Color getHealthStatusColor() {
    if (_healthScore >= 90) return Colors.green;
    if (_healthScore >= 75) return Colors.lightGreen;
    if (_healthScore >= 60) return Colors.orange;
    if (_healthScore >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  /// Get detailed status description
  String getHealthStatusDescription() {
    if (_healthScore >= 90) {
      return 'Your health metrics are excellent. Keep up the great work!';
    } else if (_healthScore >= 75) {
      return 'Your health metrics are good. Minor improvements possible.';
    } else if (_healthScore >= 60) {
      return 'Your health metrics are fair. Consider lifestyle changes.';
    } else if (_healthScore >= 40) {
      return 'Your health metrics need attention. Please consult a healthcare provider.';
    }
    return 'Your health metrics are critical. Seek medical attention.';
  }

  /// Get human-readable time since last update
  String getTimeAgo() {
    if (_lastUpdated == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  /// Get count of available metrics
  int getAvailableMetricsCount() {
    int count = 0;
    if (_componentScores['bmi']! > 0) count++;
    if (_componentScores['heartRate']! > 0) count++;
    if (_componentScores['spo2']! > 0) count++;
    if (_componentScores['bloodSugar']! > 0) count++;
    if (_componentScores['ecgHeartRate']! > 0) count++;
    return count;
  }

  /// Force recalculation of health score
  void recalculate() {
    _calculateHealthScore();
  }

  @override
  void dispose() {
    bmiController.removeListener(_onDataChanged);
    sensorProvider.removeListener(_onDataChanged);
    bloodSugarController?.removeListener(_onDataChanged);
    super.dispose();
  }
}