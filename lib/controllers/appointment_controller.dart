import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';

class AppointmentController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get stream of all appointments
  Stream<QuerySnapshot> get appointmentsStream {
    return _firestore.collectionGroup('appointments').snapshots();
  }

  // Get available appointments
  List<DocumentSnapshot> filterAvailableAppointments(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? "available";
      return status == "available";
    }).toList();
  }

  // Get user's appointments (pending or booked)
  List<DocumentSnapshot> filterUserAppointments(
    List<DocumentSnapshot> docs, 
    String userId
  ) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final patientId = data['patientId'];
      final status = data['status'] ?? "available";
      
      return patientId == userId && 
            (status == "pending" || status == "booked");
    }).toList();
  }

  // Get doctor information
  Future<Map<String, dynamic>?> getDoctorInfo(String doctorId) async {
    try {
      final docSnap = await _firestore.collection('users').doc(doctorId).get();
      if (docSnap.exists) {
        return docSnap.data();
      }
      return null;
    } catch (e) {
      print('Error getting doctor info: $e');
      return null;
    }
  }

  // Request appointment
  Future<bool> requestAppointment(
    String doctorId,
    String appointmentId,
    String userId,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final docRef = _firestore
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.update({
        'status': 'pending',
        'patientId': userId,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to request appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(
    String doctorId,
    String appointmentId,
  ) async {
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
        'requestedAt': FieldValue.delete(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to cancel appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required bool isDarkMode,
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
                backgroundColor: AppTheme.lightgreen,
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
}
