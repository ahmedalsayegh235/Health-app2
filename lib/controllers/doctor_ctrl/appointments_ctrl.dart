import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsController {
  final String doctorId;

  AppointmentsController({required this.doctorId});

  // Create new appointment
  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final appointmentsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments');

      await appointmentsRef.add(appointmentData);
    } catch (e) {
      rethrow;
    }
  }

  // Accept appointment
  Future<void> acceptAppointment(String appointmentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      final snap = await docRef.get();
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final patientId = data['patientId'];

      String patientName = "";
      if (patientId != null) {
        final patientSnap = await FirebaseFirestore.instance
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
    } catch (e) {
      rethrow;
    }
  }

  // Reject appointment
  Future<void> rejectAppointment(String appointmentId) async {
    try {
      final docRef = FirebaseFirestore.instance
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
    } catch (e) {
      rethrow;
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.update({
        'status': 'available',
        'patientId': FieldValue.delete(),
        'patientName': FieldValue.delete(),
        'requestedAt': FieldValue.delete(),
        'acceptedAt': FieldValue.delete(),
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  // Cleanup past appointments
  Future<void> cleanupPastAppointments() async {
    try {
      final now = DateTime.now();
      final appointmentsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments');

      final snapshot = await appointmentsRef.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final endTime = (data['endTime'] as Timestamp).toDate();

        if (endTime.isBefore(now.subtract(const Duration(hours: 24)))) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Stats calculator
  Map<String, int> calculateStats(List<DocumentSnapshot> docs) {
    int available = 0;
    int pending = 0;
    int booked = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? 'available';

      switch (status) {
        case 'available':
          available++;
          break;
        case 'pending':
          pending++;
          break;
        case 'booked':
          booked++;
          break;
      }
    }

    return {'available': available, 'pending': pending, 'booked': booked};
  }

  // Stream helper
  Stream<QuerySnapshot> getAppointmentsByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .collection('appointments')
        .where('status', isEqualTo: status)
        .orderBy('startTime')
        .snapshots();
  }
}
