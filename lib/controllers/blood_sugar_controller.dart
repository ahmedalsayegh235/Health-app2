import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/Reading.dart';

class BloodSugarController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HealthReading> _bloodSugarReadings = [];
  HealthReading? _latestBloodSugar;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HealthReading> get bloodSugarReadings => _bloodSugarReadings;
  HealthReading? get latestBloodSugar => _latestBloodSugar;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _auth.currentUser?.uid;

  /// Get blood sugar category text based on ADA 2025 Standards
  static String getBloodSugarCategory(double bloodSugar, String readingType) {
    if (readingType == 'fasting') {
      // ADA Fasting Glucose Standards
      if (bloodSugar < 70) return 'Hypoglycemia';
      if (bloodSugar < 100) return 'Normal';
      if (bloodSugar < 110) return 'Prediabetes (Low)';
      if (bloodSugar < 126) return 'Prediabetes (High)';
      if (bloodSugar < 151) return 'Diabetes (Mild)';
      if (bloodSugar < 201) return 'Diabetes (Moderate)';
      return 'Diabetes (Severe)';
    } else if (readingType == 'post_meal') {
      // Post-meal standards (< 140 mg/dL is normal)
      if (bloodSugar < 70) return 'Hypoglycemia';
      if (bloodSugar < 140) return 'Normal';
      if (bloodSugar < 180) return 'Slightly Elevated';
      if (bloodSugar < 200) return 'High';
      return 'Very High';
    } else {
      // Random reading
      if (bloodSugar < 70) return 'Hypoglycemia';
      if (bloodSugar < 140) return 'Normal';
      if (bloodSugar < 200) return 'Elevated';
      return 'Very High';
    }
  }

  /// Get blood sugar risk level
  static String getBloodSugarRiskLevel(double bloodSugar, String readingType) {
    if (readingType == 'fasting') {
      if (bloodSugar < 70) return 'Moderate-High';
      if (bloodSugar < 100) return 'Low';
      if (bloodSugar < 110) return 'Low-Moderate';
      if (bloodSugar < 126) return 'Moderate';
      if (bloodSugar < 151) return 'Moderate-High';
      if (bloodSugar < 201) return 'High';
      return 'Very High';
    } else if (readingType == 'post_meal') {
      if (bloodSugar < 70) return 'Moderate-High';
      if (bloodSugar < 140) return 'Low';
      if (bloodSugar < 180) return 'Low-Moderate';
      if (bloodSugar < 200) return 'Moderate';
      return 'High';
    } else {
      if (bloodSugar < 70) return 'Moderate-High';
      if (bloodSugar < 140) return 'Low';
      if (bloodSugar < 200) return 'Moderate';
      return 'High';
    }
  }

  /// Check if blood sugar requires medical attention
  static bool requiresMedicalAttention(double bloodSugar, String readingType) {
    // Based on ADA standards: hypoglycemia or diabetes range
    if (bloodSugar < 70) return true; // Hypoglycemia

    if (readingType == 'fasting') {
      return bloodSugar >= 126; // Diabetes range
    } else if (readingType == 'post_meal') {
      return bloodSugar >= 200; // Very high
    } else {
      return bloodSugar >= 200; // Very high
    }
  }

  /// Get blood sugar category color
  static Color getBloodSugarCategoryColor(double bloodSugar, String readingType) {
    if (bloodSugar < 70) return Colors.red; // Hypoglycemia

    if (readingType == 'fasting') {
      if (bloodSugar < 100) return Colors.green; // Normal
      if (bloodSugar < 110) return Colors.blue; // Prediabetes (Low)
      if (bloodSugar < 126) return Colors.orange; // Prediabetes (High)
      if (bloodSugar < 151) return Colors.deepOrange; // Diabetes (Mild)
      if (bloodSugar < 201) return Colors.red; // Diabetes (Moderate)
      return Colors.red.shade900; // Diabetes (Severe)
    } else if (readingType == 'post_meal') {
      if (bloodSugar < 140) return Colors.green; // Normal
      if (bloodSugar < 180) return Colors.blue; // Slightly Elevated
      if (bloodSugar < 200) return Colors.orange; // High
      return Colors.red; // Very High
    } else {
      if (bloodSugar < 140) return Colors.green; // Normal
      if (bloodSugar < 200) return Colors.orange; // Elevated
      return Colors.red; // Very High
    }
  }

  /// Get health advice based on blood sugar and ADA standards
  static String getBloodSugarAdvice(double bloodSugar, String readingType) {
    final category = getBloodSugarCategory(bloodSugar, readingType);

    if (category == 'Hypoglycemia') {
      return 'Your blood sugar is dangerously low (hypoglycemia). Immediately consume 15-20g of fast-acting carbohydrates. If symptoms persist, seek medical attention.';
    }

    if (readingType == 'fasting') {
      if (category == 'Normal') {
        return 'Excellent! Your fasting blood sugar is in the normal range. Continue your healthy lifestyle with balanced nutrition and regular exercise.';
      } else if (category == 'Prediabetes (Low)') {
        return 'Your fasting blood sugar indicates early prediabetes. Lifestyle changes including diet and exercise can help prevent progression to diabetes.';
      } else if (category == 'Prediabetes (High)') {
        return 'Your fasting blood sugar indicates prediabetes. Please consult a healthcare provider for guidance on diet, exercise, and possible monitoring.';
      } else if (category == 'Diabetes (Mild)') {
        return 'Your fasting blood sugar indicates mild diabetes. Medical consultation is necessary for proper diabetes management and treatment planning.';
      } else if (category == 'Diabetes (Moderate)') {
        return 'Your fasting blood sugar indicates moderate diabetes. Immediate medical consultation is recommended for comprehensive diabetes management.';
      } else {
        return 'Your fasting blood sugar indicates severe diabetes. Urgent medical consultation is required for proper treatment and blood sugar control.';
      }
    } else if (readingType == 'post_meal') {
      if (category == 'Normal') {
        return 'Great! Your post-meal blood sugar is in the normal range. Keep up your healthy eating habits.';
      } else if (category == 'Slightly Elevated') {
        return 'Your post-meal blood sugar is slightly elevated. Consider reviewing your meal portions and carbohydrate intake with a healthcare provider.';
      } else if (category == 'High') {
        return 'Your post-meal blood sugar is high. Please consult a healthcare provider to evaluate your diet and possible need for diabetes management.';
      } else {
        return 'Your post-meal blood sugar is very high. Medical consultation is strongly recommended for evaluation and treatment.';
      }
    } else {
      if (category == 'Normal') {
        return 'Your blood sugar is in the normal range. Continue maintaining a healthy lifestyle.';
      } else if (category == 'Elevated') {
        return 'Your blood sugar is elevated. Consider consulting a healthcare provider for evaluation and guidance on blood sugar management.';
      } else {
        return 'Your blood sugar is very high. Please consult a healthcare provider for proper evaluation and treatment.';
      }
    }
  }

  /// Add new blood sugar reading
  Future<bool> addBloodSugarReading({
    required double value,
    required String readingType, // 'fasting', 'post_meal', or 'random'
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

      final timestamp = Timestamp.now();
      final category = getBloodSugarCategory(value, readingType);

      // Create blood sugar reading
      final bloodSugarReading = HealthReading(
        timestamp: timestamp.toDate(),
        value: value,
        note: note ?? 'Blood Sugar: ${value.toStringAsFixed(1)} mg/dL - $category',
        type: 'blood_sugar',
        metadata: {
          'readingType': readingType,
          'category': category,
          'unit': 'mg/dL',
        },
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_readings')
          .doc(bloodSugarReading.id)
          .set({
        'id': bloodSugarReading.id,
        'timestamp': timestamp,
        'value': bloodSugarReading.value,
        'note': bloodSugarReading.note,
        'type': bloodSugarReading.type,
        'metadata': bloodSugarReading.metadata,
      });

      // Update local state
      _bloodSugarReadings.insert(0, bloodSugarReading);
      _latestBloodSugar = bloodSugarReading;

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

  /// Stream of blood sugar readings
  Stream<List<HealthReading>> bloodSugarStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('health_readings')
        .where('type', isEqualTo: 'blood_sugar')
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
      
      _bloodSugarReadings = readings;
      if (readings.isNotEmpty) {
        _latestBloodSugar = readings.first;
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

      _bloodSugarReadings.removeWhere((r) => r.id == readingId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}