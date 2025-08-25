import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:health/views/tabs/widgets/activity/widgets/reading_diaglog.dart';
import '../models/Reading.dart';

class EcgReadingController extends ChangeNotifier {
  final List<HealthReading> _readings = [];
  final List<double> _ecgWaveData = [];
  bool _isRecording = false;

  // Animation controllers
  final AnimationController waveController;
  final AnimationController pulseController;

  EcgReadingController({
    required this.waveController,
    required this.pulseController,
  });

  List<HealthReading> get readings => List.unmodifiable(_readings);
  List<double> get ecgWaveData => List.unmodifiable(_ecgWaveData);
  bool get isRecording => _isRecording;

  void generateSampleData() {
    _readings.clear();
    _readings.addAll([
      HealthReading(timestamp: DateTime.now(), value: 0.8, note: 'Normal sinus rhythm', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 2)), value: 0.7, note: 'Regular rhythm', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 4)), value: 0.9, note: 'Slight irregularity detected', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 6)), value: 0.8, note: 'Normal rhythm', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 8)), value: 0.75, note: 'Healthy pattern', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 12)), value: 0.85, note: 'Good rhythm', type: 'ecg'),
      HealthReading(timestamp: DateTime.now().subtract(const Duration(hours: 24)), value: 0.8, note: 'Normal', type: 'ecg'),
    ]);
    notifyListeners();
  }

  void generateECGWave() {
    _ecgWaveData.clear();
    for (int i = 0; i < 200; i++) {
      double x = i / 20.0;
      double y = 0;
      if (x % 1.0 < 0.1) {
        y = math.sin(x * 100) * 0.8; // QRS complex
      } else if (x % 1.0 < 0.3) {
        y = math.sin(x * 10) * 0.2; // T wave
      } else {
        y = math.sin(x * 5) * 0.05; // Baseline
      }
      _ecgWaveData.add(y);
    }
    notifyListeners();
  }

  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();

    if (_isRecording) {
      waveController.repeat();
      pulseController.repeat(reverse: true);

      Future.delayed(const Duration(seconds: 10), () {
        if (_isRecording) stopRecording();
      });
    } else {
      waveController.stop();
      pulseController.stop();
    }
  }

  void stopRecording() {
    _isRecording = false;
    waveController.stop();
    pulseController.stop();

    final newReading = HealthReading(
      timestamp: DateTime.now(),
      value: 0.7 + (0.3 * (DateTime.now().millisecond % 10) / 10),
      note: 'Just recorded',
      type: 'ecg',
    );

    _readings.insert(0, newReading);
    notifyListeners();
  }

  void showReadingDetail(BuildContext context, HealthReading reading, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => ReadingDetailDialog(
        title: 'ECG',
        reading: reading,
        isDark: isDark,
        unit: 'mV',
        color: Colors.green,
      ),
    );
  }
}
