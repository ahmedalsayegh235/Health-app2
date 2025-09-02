import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';
import 'dart:async';

class DrAppointmentController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _cleanupTimer;
  
  bool _isLoading = false;
  String? _error;
  Map<String, int> _stats = {'available': 0, 'pending': 0, 'booked': 0};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get stats => _stats;

  DrAppointmentController() {
    _startAutomaticCleanup();
  }

  // Start automatic cleanup of past appointments
  void _startAutomaticCleanup() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _cleanupPastAppointments();
    });
    
    // Run cleanup immediately
    Future.delayed(const Duration(seconds: 5), () {
      _cleanupPastAppointments();
    });
  }

  // Get doctor's appointments stream
  Stream<QuerySnapshot> getDoctorAppointmentsStream(String doctorId, String status) {
    return _firestore
        .collection('users')
        .doc(doctorId)
        .collection('appointments')
        .where('status', isEqualTo: status)
        .orderBy('startTime', descending: false)
        .snapshots();
  }

  // Get all patients for dropdown
  Stream<QuerySnapshot> get patientsStream {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots();
  }

  // Accept appointment request
  Future<bool> acceptAppointment(String doctorId, String appointmentId) async {
    try {
      _setLoading(true);
      _clearError();

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      final snap = await docRef.get();
      if (!snap.exists) {
        _setError('Appointment not found');
        _setLoading(false);
        return false;
      }

      final data = snap.data() as Map<String, dynamic>;
      final patientId = data['patientId'];

      String patientName = "";
      if (patientId != null) {
        final patientSnap = await _firestore
            .collection('users')
            .doc(patientId)
            .get();
        if (patientSnap.exists) {
          final patientData = patientSnap.data() as Map<String, dynamic>;
          patientName = patientData['name'] ?? "";
        }
      }

      await docRef.update({
        'status': 'booked',
        'patientName': patientName,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      await _updateStats(doctorId);
      return true;
    } catch (e) {
      _setError('Failed to accept appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Reject appointment request
  Future<bool> rejectAppointment(String doctorId, String appointmentId) async {
    try {
      _setLoading(true);
      _clearError();

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.update({
        'status': 'available',
        'patientId': FieldValue.delete(),
        'patientName': FieldValue.delete(),
        'requestedAt': FieldValue.delete(),
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      await _updateStats(doctorId);
      return true;
    } catch (e) {
      _setError('Failed to reject appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Cancel booked appointment
  Future<bool> cancelAppointment(String doctorId, String appointmentId) async {
    try {
      _setLoading(true);
      _clearError();

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.update({
        'status': 'available',
        'patientId': FieldValue.delete(),
        'patientName': FieldValue.delete(),
        'acceptedAt': FieldValue.delete(),
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': 'doctor',
      });

      _setLoading(false);
      await _updateStats(doctorId);
      return true;
    } catch (e) {
      _setError('Failed to cancel appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete appointment completely
  Future<bool> deleteAppointment(String doctorId, String appointmentId) async {
    try {
      _setLoading(true);
      _clearError();

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.delete();

      _setLoading(false);
      await _updateStats(doctorId);
      return true;
    } catch (e) {
      _setError('Failed to delete appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Create new appointment
  Future<bool> createAppointment({
    required String doctorId,
    required DateTime startTime,
    required DateTime endTime,
    String? patientId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check for time conflicts
      final conflicts = await _checkTimeConflict(doctorId, startTime, endTime);
      if (conflicts) {
        _setError('Time slot conflicts with existing appointment');
        _setLoading(false);
        return false;
      }

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc();

      String? patientName;
      if (patientId != null) {
        final patientDoc = await _firestore.collection('users').doc(patientId).get();
        if (patientDoc.exists) {
          final patientData = patientDoc.data() as Map<String, dynamic>;
          patientName = patientData['name'];
        }
      }

      final appointmentData = <String, dynamic>{
        'doctorId': doctorId,
        'startTime': Timestamp.fromDate(startTime.toUtc()),
        'endTime': Timestamp.fromDate(endTime.toUtc()),
        'status': patientId == null ? 'available' : 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (patientId != null) {
        appointmentData['patientId'] = patientId;
      }
      if (patientName != null) {
        appointmentData['patientName'] = patientName;
      }
      if (notes != null && notes.isNotEmpty) {
        appointmentData['notes'] = notes;
      }

      await docRef.set(appointmentData);

      _setLoading(false);
      await _updateStats(doctorId);
      return true;
    } catch (e) {
      _setError('Failed to create appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Check for time conflicts
  Future<bool> _checkTimeConflict(String doctorId, DateTime startTime, DateTime endTime) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('startTime', isLessThan: Timestamp.fromDate(endTime.toUtc()))
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final existingEnd = (data['endTime'] as Timestamp).toDate();
        if (existingEnd.isAfter(startTime)) {
          return true; // Conflict found
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Cleanup past appointments automatically
  Future<void> _cleanupPastAppointments() async {
    try {
      final now = DateTime.now();
      final cutoffTime = now.subtract(const Duration(hours: 2)); // 2 hours grace period

      // Get all doctors
      final doctorsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      for (final doctorDoc in doctorsQuery.docs) {
        final appointmentsQuery = await _firestore
            .collection('users')
            .doc(doctorDoc.id)
            .collection('appointments')
            .where('endTime', isLessThan: Timestamp.fromDate(cutoffTime.toUtc()))
            .get();

        final batch = _firestore.batch();
        for (final appointmentDoc in appointmentsQuery.docs) {
          batch.delete(appointmentDoc.reference);
        }

        if (appointmentsQuery.docs.isNotEmpty) {
          await batch.commit();
          debugPrint('Cleaned up ${appointmentsQuery.docs.length} past appointments for doctor ${doctorDoc.id}');
        }
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  // Manual cleanup trigger
  Future<void> manualCleanup(String doctorId) async {
    try {
      _setLoading(true);
      
      final now = DateTime.now();
      final appointmentsQuery = await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('endTime', isLessThan: Timestamp.fromDate(now.toUtc()))
          .get();

      final batch = _firestore.batch();
      for (final appointmentDoc in appointmentsQuery.docs) {
        batch.delete(appointmentDoc.reference);
      }

      if (appointmentsQuery.docs.isNotEmpty) {
        await batch.commit();
      }

      _setLoading(false);
      await _updateStats(doctorId);
    } catch (e) {
      _setError('Failed to cleanup appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Update appointment statistics
  Future<void> _updateStats(String doctorId) async {
    try {
      final available = await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('status', isEqualTo: 'available')
          .get();

      final pending = await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('status', isEqualTo: 'pending')
          .get();

      final booked = await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('status', isEqualTo: 'booked')
          .get();

      _stats = {
        'available': available.docs.length,
        'pending': pending.docs.length,
        'booked': booked.docs.length,
      };
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating stats: $e');
    }
  }

  // Get appointment statistics
  Future<void> loadStats(String doctorId) async {
    await _updateStats(doctorId);
  }

  // Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required bool isDarkMode,
    Color confirmColor = Colors.red,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppTheme.textColor(isDarkMode),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDarkMode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppTheme.textSecondaryColor(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}