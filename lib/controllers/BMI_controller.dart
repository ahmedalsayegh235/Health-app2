import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/Reading.dart';

class BmiController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HealthReading> _bmiReadings = [];
  HealthReading? _latestBmi;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HealthReading> get bmiReadings => _bmiReadings;
  HealthReading? get latestBmi => _latestBmi;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _auth.currentUser?.uid;

  /// Calculate BMI from weight (kg) and height (cm)
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category text
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Get BMI category color
  static Color getBmiCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  /// Get health advice based on BMI
  static String getBmiAdvice(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Consider consulting a nutritionist for a healthy weight gain plan.';
    } else if (bmi < 25) {
      return 'Great! You have a healthy weight. Keep maintaining your current lifestyle.';
    } else if (bmi < 30) {
      return 'You are slightly overweight. Consider regular exercise and a balanced diet.';
    } else {
      return 'You are in the obese range. Please consult a healthcare professional for guidance.';
    }
  }

  /// Add new BMI reading with weight and height
  Future<bool> addBmiReading({
    required double weight,
    required double height,
    String? note,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final bmi = calculateBmi(weight, height);
      final timestamp = Timestamp.now();
      final category = getBmiCategory(bmi);

      // Create BMI reading
      final bmiReading = HealthReading(
        timestamp: timestamp.toDate(),
        value: bmi,
        note: 'BMI: ${bmi.toStringAsFixed(1)} - $category',
        type: 'bmi',
        metadata: {
          'weight': weight,
          'height': height,
          'category': category,
          'unit': 'kg/m²',
        },
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_readings')
          .doc(bmiReading.id)
          .set({
        'id': bmiReading.id,
        'timestamp': timestamp,
        'value': bmiReading.value,
        'note': bmiReading.note,
        'type': bmiReading.type,
        'metadata': bmiReading.metadata,
      });

      // Update local state
      _bmiReadings.insert(0, bmiReading);
      _latestBmi = bmiReading;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
   
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Stream of BMI readings
  Stream<List<HealthReading>> bmiStream() {
    final user = _auth.currentUser;
    if (user == null) {

      return Stream.value([]);
    }


    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('health_readings')
        .where('type', isEqualTo: 'bmi')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {

      
      final readings = snapshot.docs.map((doc) {
        final data = doc.data();
        return HealthReading(
          id: data['id'] as String,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          value: (data['value'] as num).toDouble(),
          note: data['note'] as String? ?? '',
          type: data['type'] as String,
          metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
        );
      }).toList();
      
      _bmiReadings = readings;
      if (readings.isNotEmpty) {
        _latestBmi = readings.first;
      }
      notifyListeners();
      return readings;
    });
  }

  /// Delete a reading
  Future<bool> deleteReading(String readingId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_readings')
          .doc(readingId)
          .delete();

      _bmiReadings.removeWhere((r) => r.id == readingId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}