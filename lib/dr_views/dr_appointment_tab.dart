import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/dr_views/appointments_widgets/appointment_card.dart';
import 'package:health/dr_views/appointments_widgets/appointment_dialog.dart';
import 'package:health/dr_views/appointments_widgets/appointment_header.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:provider/provider.dart';
import '../controllers/user_provider.dart';
import '../helpers/theme_provider.dart';

class DrAppointmentTab extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrAppointmentTab({super.key, required this.scaffoldKey});

  @override
  State<DrAppointmentTab> createState() => _DrAppointmentTabState();
}

class _DrAppointmentTabState extends State<DrAppointmentTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _fabController;

  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<Offset> _listSlideAnimation;
  late Animation<double> _fabScaleAnimation;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
    _startAnimations();

    // Auto cleanup past appointments every hour
    _scheduleAutoCleanup();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
    );

    _listSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
        );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fabController.forward();
    });
  }

  void _scheduleAutoCleanup() {
    // Run cleanup every hour
    Future.delayed(const Duration(hours: 1), () {
      if (mounted) {
        _cleanupPastAppointments();
        _scheduleAutoCleanup();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _listController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _acceptAppointment(String doctorId, String appointmentId) async {
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

      _showSuccessSnackBar('Appointment accepted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to accept appointment: ${e.toString()}');
    }
  }

  Future<void> _rejectAppointment(String doctorId, String appointmentId) async {
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

      _showSuccessSnackBar('Appointment rejected');
    } catch (e) {
      _showErrorSnackBar('Failed to reject appointment: ${e.toString()}');
    }
  }

  Future<void> _cancelAppointment(String doctorId, String appointmentId) async {
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

      _showSuccessSnackBar('Appointment cancelled');
    } catch (e) {
      _showErrorSnackBar('Failed to cancel appointment: ${e.toString()}');
    }
  }

  Future<void> _deleteAppointment(String doctorId, String appointmentId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .doc(appointmentId);

      await docRef.delete();

      _showSuccessSnackBar('Appointment deleted');
    } catch (e) {
      _showErrorSnackBar('Failed to delete appointment: ${e.toString()}');
    }
  }

  Future<void> _cleanupPastAppointments() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.id == null) return;

    try {
      final now = DateTime.now();
      final appointmentsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.id!)
          .collection('appointments');

      final snapshot = await appointmentsRef.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final endTime = (data['endTime'] as Timestamp).toDate();

        // Delete appointments that ended more than 24 hours ago
        if (endTime.isBefore(now.subtract(const Duration(hours: 24)))) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
      _showSuccessSnackBar('Past appointments cleaned up');
    } catch (e) {
      _showErrorSnackBar('Failed to cleanup appointments: ${e.toString()}');
    }
  }

  Future<void> _showCreateDialog() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    if (user?.id == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CreateAppointmentDialog(doctorId: user!.id!, isDarkMode: isDarkMode),
    );

    if (result == true) {
      // Restart animations after creation
      _listController.reset();
      _listController.forward();
    }
  }

  Map<String, int> _calculateStats(List<DocumentSnapshot> docs) {
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.lightgreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAppointmentList(
    String doctorId,
    bool isDarkMode,
    String status,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .where('status', isEqualTo: status)
          .orderBy('startTime', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return _buildErrorState(isDarkMode);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(isDarkMode);
        }

        final docs = snapshot.data!.docs;
        // Filter out past appointments for display
        final now = DateTime.now();
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endTime = (data['endTime'] as Timestamp).toDate();
          return endTime.isAfter(now.subtract(const Duration(hours: 1)));
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState(isDarkMode, status);
        }

        return SlideTransition(
          position: _listSlideAnimation,
          child: FadeTransition(
            opacity: _listFadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = filteredDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final patientName = data['patientName'] ?? '';

                return DrAppointmentCard(
                  appointment: doc,
                  patientName: patientName,
                  status: status,
                  isDarkMode: isDarkMode,
                  index: index,
                  onAccept: () => _acceptAppointment(doctorId, doc.id),
                  onReject: () => _rejectAppointment(doctorId, doc.id),
                  onCancel: () => _cancelAppointment(doctorId, doc.id),
                  onDelete: () => _deleteAppointment(doctorId, doc.id),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.lightgreen, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading appointments...',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDarkMode),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              color: AppTheme.textColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, String status) {
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'available':
        icon = Icons.event_available;
        title = 'No available appointments';
        subtitle = 'Create your first appointment to get started';
        break;
      case 'pending':
        icon = Icons.pending_actions;
        title = 'No pending requests';
        subtitle = 'Patient requests will appear here';
        break;
      case 'booked':
        icon = Icons.check_circle;
        title = 'No booked appointments';
        subtitle = 'Accepted appointments will show here';
        break;
      default:
        icon = Icons.event;
        title = 'No appointments';
        subtitle = 'Start managing your schedule';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightgreen.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: AppTheme.lightgreen, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textColor(isDarkMode),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final user = Provider.of<UserProvider>(context).user;
  final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

  if (user?.id == null) {
    return const Center(child: Text('Please login as a doctor'));
  }

  return Scaffold(
    backgroundColor: AppTheme.backgroundColor(isDarkMode),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.id!)
          .collection('appointments')
          .snapshots(),
      builder: (context, snapshot) {
        final stats = snapshot.hasData
            ? _calculateStats(snapshot.data!.docs)
            : {'available': 0, 'pending': 0, 'booked': 0};

        return Column(
          children: [
            SlideTransition(
              position: _headerSlideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: DrAppointmentHeader(
                  isDark: isDarkMode,
                  tabController: _tabController,
                  scaffoldKey: widget.scaffoldKey, 
                  stats: stats,
                  onCreateAppointment: _showCreateDialog,
                  onCleanup: _cleanupPastAppointments,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentList(user.id!, isDarkMode, 'available'),
                  _buildAppointmentList(user.id!, isDarkMode, 'pending'),
                  _buildAppointmentList(user.id!, isDarkMode, 'booked'),
                ],
              ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.lightgreen,
        foregroundColor: Colors.white,
        elevation: 8,
        label: const Text('New Appointment'),
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

}
