import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProvider with ChangeNotifier {
  List<Map<String, dynamic>> _activities = [];
  DateTime? _lastSavedDate;

  List<Map<String, dynamic>> get activities => _activities;

  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();

    // Load last saved date
    final lastDateString = prefs.getString('lastSavedDate');
    if (lastDateString != null) {
      _lastSavedDate = DateTime.parse(lastDateString);
    }

    // Reset if the day changed
    if (_lastSavedDate == null ||
        !_isSameDay(_lastSavedDate!, DateTime.now())) {
      _activities = [];
      await prefs.remove('activities');
      await prefs.setString('lastSavedDate', DateTime.now().toIso8601String());
    } else {
      // Load saved activities
      final savedActivities = prefs.getString('activities');
      if (savedActivities != null) {
        _activities = List<Map<String, dynamic>>.from(
            jsonDecode(savedActivities) as List);
      }
    }

    notifyListeners();
  }

  Future<void> addActivity(Map<String, dynamic> activity) async {
    _activities.insert(0, activity); // add newest at top
    notifyListeners();
    await _saveActivities();
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('activities', jsonEncode(_activities));
    prefs.setString('lastSavedDate', DateTime.now().toIso8601String());
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
