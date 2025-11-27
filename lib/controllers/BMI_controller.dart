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

  /// Get BMI category text based on WHO classification
  static String getBmiCategory(double bmi) {
    if (bmi < 15.0) return 'Underweight (Severe)';
    if (bmi < 17.0) return 'Underweight (Moderate)';
    if (bmi < 18.5) return 'Underweight (Mild)';
    if (bmi <= 24.9) return 'Normal/Optimal';
    if (bmi < 27.0) return 'Overweight (Grade I)';
    if (bmi < 30.0) return 'Overweight (Grade II)';
    if (bmi < 35.0) return 'Obese Class I';
    if (bmi < 40.0) return 'Obese Class II';
    return 'Obese Class III';
  }

  /// Get BMI risk level based on WHO classification
  static String getBmiRiskLevel(double bmi) {
    if (bmi < 15.0) return 'High';
    if (bmi < 17.0) return 'Moderate';
    if (bmi < 18.5) return 'Low-Moderate';
    if (bmi <= 24.9) return 'Low';
    if (bmi < 27.0) return 'Low-Moderate';
    if (bmi < 30.0) return 'Moderate';
    if (bmi < 35.0) return 'Moderate-High';
    if (bmi < 40.0) return 'High';
    return 'Very High';
  }

  /// Check if BMI requires medical attention
  static bool requiresMedicalAttention(double bmi) {
    // Based on WHO standards: severe underweight, or any obesity class
    return bmi < 17.0 || bmi >= 30.0;
  }

  /// Get BMI category color
  static Color getBmiCategoryColor(double bmi) {
    if (bmi < 15.0) return Colors.red; // Severe underweight
    if (bmi < 17.0) return Colors.orange; // Moderate underweight
    if (bmi < 18.5) return Colors.blue; // Mild underweight
    if (bmi <= 24.9) return Colors.green; // Normal/Optimal
    if (bmi < 27.0) return Colors.blue; // Overweight Grade I
    if (bmi < 30.0) return Colors.orange; // Overweight Grade II
    if (bmi < 35.0) return Colors.deepOrange; // Obese Class I
    if (bmi < 40.0) return Colors.red; // Obese Class II
    return Colors.red.shade900; // Obese Class III
  }

  /// Get health advice based on BMI
  static String getBmiAdvice(double bmi) {
    if (bmi < 15.0) {
      return 'Your BMI indicates severe underweight. This requires immediate medical attention. Please consult a healthcare professional.';
    } else if (bmi < 17.0) {
      return 'Your BMI indicates moderate underweight. Consider consulting a nutritionist and healthcare provider for a healthy weight gain plan.';
    } else if (bmi < 18.5) {
      return 'You are mildly underweight. Consider consulting a nutritionist for a healthy weight gain plan.';
    } else if (bmi <= 24.9) {
      return 'Great! You have a healthy weight. Keep maintaining your current lifestyle with balanced nutrition and regular exercise.';
    } else if (bmi < 27.0) {
      return 'You are slightly overweight (Grade I). Consider regular physical activity and monitoring your diet.';
    } else if (bmi < 30.0) {
      return 'You are overweight (Grade II). Regular exercise and a balanced diet are recommended. Consider consulting a healthcare professional.';
    } else if (bmi < 35.0) {
      return 'Your BMI indicates Class I Obesity. Please consult a healthcare professional for personalized guidance on weight management.';
    } else if (bmi < 40.0) {
      return 'Your BMI indicates Class II Obesity. Medical consultation is strongly recommended for comprehensive weight management support.';
    } else {
      return 'Your BMI indicates Class III Obesity. Immediate medical consultation is strongly recommended for your health and wellbeing.';
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