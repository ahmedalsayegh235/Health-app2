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

  // Get blood sugar category text
  static String getBloodSugarCategory(double bloodSugar, String readingType) {
    if (readingType == 'fasting') {
      if (bloodSugar < 70) return 'Low';
      if (bloodSugar < 100) return 'Normal';
      if (bloodSugar < 126) return 'Prediabetes';
      return 'Diabetes';
    } else if (readingType == 'post_meal') {
      if (bloodSugar < 70) return 'Low';
      if (bloodSugar < 140) return 'Normal';
      if (bloodSugar < 200) return 'Prediabetes';
      return 'Diabetes';
    } else {
      // Random reading
      if (bloodSugar < 70) return 'Low';
      if (bloodSugar < 140) return 'Normal';
      if (bloodSugar < 200) return 'High';
      return 'Very High';
    }
  }

  /// Get blood sugar category color
  static Color getBloodSugarCategoryColor(double bloodSugar, String readingType) {
    final category = getBloodSugarCategory(bloodSugar, readingType);
    if (category == 'Low') return Colors.blue;
    if (category == 'Normal') return Colors.green;
    if (category == 'Prediabetes' || category == 'High') return Colors.orange;
    return Colors.red;
  }

  /// Get health advice based on blood sugar
  static String getBloodSugarAdvice(double bloodSugar, String readingType) {
    final category = getBloodSugarCategory(bloodSugar, readingType);
    
    if (category == 'Low') {
      return 'Your blood sugar is low. Consider having a quick-acting carbohydrate and consult your doctor if this persists.';
    } else if (category == 'Normal') {
      return 'Great! Your blood sugar is in the normal range. Keep up your healthy lifestyle.';
    } else if (category == 'Prediabetes' || category == 'High') {
      return 'Your blood sugar is elevated. Consider regular exercise, a balanced diet, and consult your healthcare provider.';
    } else {
      return 'Your blood sugar is very high. Please consult your healthcare provider immediately for proper management.';
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