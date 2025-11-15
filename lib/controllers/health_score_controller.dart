import 'package:flutter/material.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/controllers/sensor_provider.dart';

class HealthScoreProvider extends ChangeNotifier {
  final BmiController bmiController;
  final SensorProvider sensorProvider;

  int _healthScore = 0;
  DateTime? _lastUpdated;
  Map<String, int> _componentScores = {
    'bmi': 0,
    'heartRate': 0,
    'spo2': 0,
  };

  // Track last reading IDs to see if anyhting changed
  String? _lastBmiId;
  String? _lastHrId;
  String? _lastSpo2Id;

  int get healthScore => _healthScore;
  DateTime? get lastUpdated => _lastUpdated;
  Map<String, int> get componentScores => _componentScores;

  HealthScoreProvider({
    required this.bmiController,
    required this.sensorProvider,
  }) {
    // listen to changes
    bmiController.addListener(_onDataChanged);
    sensorProvider.addListener(_onDataChanged);
    
    // Initial calculation after a delay
    Future.delayed(const Duration(milliseconds: 500), _onDataChanged);
  }

  // only recalculate when data changes
  void _onDataChanged() {
    bool hasChanged = false;

    // Check if BMI reading is new
    final currentBmiId = bmiController.latestBmi?.id;
    if (currentBmiId != _lastBmiId) {
      _lastBmiId = currentBmiId;
      hasChanged = true;
    }

    // Check if Heart Rate reading is new
    final currentHrId = sensorProvider.lastHeartRate?.id;
    if (currentHrId != _lastHrId) {
      _lastHrId = currentHrId;
      hasChanged = true;
    }

    // Check if SpO2 reading is new
    final currentSpo2Id = sensorProvider.lastSpo2?.id;
    if (currentSpo2Id != _lastSpo2Id) {
      _lastSpo2Id = currentSpo2Id;
      hasChanged = true;
    }

    // Only recalculate if something actually changed
    if (hasChanged) {
      _calculateHealthScore();
    }
  }

  void _calculateHealthScore() {
    int bmiScore = _calculateBmiScore();
    int heartRateScore = _calculateHeartRateScore();
    int spo2Score = _calculateSpo2Score();

    _componentScores = {
      'bmi': bmiScore,
      'heartRate': heartRateScore,
      'spo2': spo2Score,
    };

    // Only calculate if at least one metric is available
    int validScores = 0;
    int totalScore = 0;
    
    if (bmiScore > 0) {
      validScores++;
      totalScore += bmiScore;
    }
    if (heartRateScore > 0) {
      validScores++;
      totalScore += heartRateScore;
    }
    if (spo2Score > 0) {
      validScores++;
      totalScore += spo2Score;
    }

    // Calculate average of available scores
    if (validScores > 0) {
      _healthScore = (totalScore / validScores).round();
      _lastUpdated = DateTime.now();
    } else {
      _healthScore = 0;
      _lastUpdated = null;
    }

    notifyListeners();
  }

  int _calculateBmiScore() {
    final latestBmi = bmiController.latestBmi;
    if (latestBmi == null) return 0;

    final bmi = latestBmi.value;

    // Scoring based on BMI ranges
    if (bmi >= 18.5 && bmi < 25) {
      // Optimal range - 100 points
      return 100;
    } else if (bmi >= 25 && bmi < 27) {
      // Slightly overweight - 85-95 points
      return (95 - ((bmi - 25) * 5)).round();
    } else if (bmi >= 17 && bmi < 18.5) {
      // Slightly underweight - 80-95 points
      return (80 + ((bmi - 17) * 10)).round();
    } else if (bmi >= 27 && bmi < 30) {
      // Overweight - 70-85 points
      return (85 - ((bmi - 27) * 5)).round();
    } else if (bmi >= 30 && bmi < 35) {
      // Obese Class I - 50-70 points
      return (70 - ((bmi - 30) * 4)).round();
    } else if (bmi >= 15 && bmi < 17) {
      // Moderately underweight - 60-80 points
      return (60 + ((bmi - 15) * 10)).round();
    } else if (bmi >= 35 && bmi < 40) {
      // Obese Class II - 30-50 points
      return (50 - ((bmi - 35) * 4)).round();
    } else if (bmi >= 40) {
      // Obese Class III - 10-30 points
      return (30 - ((bmi - 40) * 2)).round().clamp(10, 30);
    } else {
      // Severely underweight - 20-60 points
      return (20 + ((bmi - 10) * 8)).round().clamp(20, 60);
    }
  }

  int _calculateHeartRateScore() {
    final latestHR = sensorProvider.lastHeartRate;
    if (latestHR == null) return 0;

    final heartRate = latestHR.value;

    // Scoring based on heart rate ranges (resting)
    if (heartRate >= 60 && heartRate <= 80) {
      // Optimal resting heart rate - 100 points
      return 100;
    } else if (heartRate > 80 && heartRate <= 90) {
      // Slightly elevated - 85-95 points
      return (95 - ((heartRate - 80) * 1)).round();
    } else if (heartRate >= 50 && heartRate < 60) {
      // Athletic/low heart rate - 90-100 points
      return (90 + ((heartRate - 50) * 1)).round();
    } else if (heartRate > 90 && heartRate <= 100) {
      // Elevated - 70-85 points
      return (85 - ((heartRate - 90) * 1.5)).round();
    } else if (heartRate > 100 && heartRate <= 110) {
      // High - 55-70 points
      return (70 - ((heartRate - 100) * 1.5)).round();
    } else if (heartRate >= 40 && heartRate < 50) {
      // Very low - 70-90 points (could be athletic or concerning)
      return (70 + ((heartRate - 40) * 2)).round();
    } else if (heartRate > 110 && heartRate <= 130) {
      // Very high - 30-55 points
      return (55 - ((heartRate - 110) * 1.25)).round();
    } else if (heartRate > 130) {
      // Dangerous high - 10-30 points
      return (30 - ((heartRate - 130) * 0.5)).round().clamp(10, 30);
    } else {
      // Dangerously low - 20-70 points
      return (20 + ((heartRate - 30) * 5)).round().clamp(20, 70);
    }
  }

  int _calculateSpo2Score() {
    final latestSpo2 = sensorProvider.lastSpo2;
    if (latestSpo2 == null) return 0;

    final spo2 = latestSpo2.value;

    // Scoring based on SpO2 levels
    if (spo2 >= 95 && spo2 <= 100) {
      // Optimal oxygen saturation - 95-100 points
      // Perfect at 98-99
      if (spo2 >= 98 && spo2 <= 99) {
        return 100;
      } else if (spo2 == 100) {
        return 98; // 100% can sometimes indicate sensor issues
      } else if (spo2 >= 96 && spo2 <= 97) {
        return 95 + ((spo2 - 96) * 2.5).round();
      } else {
        return 95;
      }
    } else if (spo2 >= 92 && spo2 < 95) {
      // Mild hypoxemia - 75-95 points
      return (75 + ((spo2 - 92) * 6.67)).round();
    } else if (spo2 >= 88 && spo2 < 92) {
      // Moderate hypoxemia - 50-75 points
      return (50 + ((spo2 - 88) * 6.25)).round();
    } else if (spo2 >= 85 && spo2 < 88) {
      // Severe hypoxemia - 30-50 points
      return (30 + ((spo2 - 85) * 6.67)).round();
    } else if (spo2 < 85) {
      // Critical hypoxemia - 10-30 points
      return (10 + ((spo2 - 80) * 4)).round().clamp(10, 30);
    } else {
      return 0;
    }
  }

  String getHealthStatus() {
    if (_healthScore >= 90) return 'Excellent';
    if (_healthScore >= 75) return 'Good';
    if (_healthScore >= 60) return 'Fair';
    if (_healthScore >= 40) return 'Poor';
    return 'Critical';
  }

  Color getHealthStatusColor() {
    if (_healthScore >= 90) return Colors.green;
    if (_healthScore >= 75) return Colors.lightGreen;
    if (_healthScore >= 60) return Colors.orange;
    if (_healthScore >= 40) return Colors.deepOrange;
    return Colors.red;
  }

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

  @override
  void dispose() {
    bmiController.removeListener(_onDataChanged);
    sensorProvider.removeListener(_onDataChanged);
    super.dispose();
  }
}