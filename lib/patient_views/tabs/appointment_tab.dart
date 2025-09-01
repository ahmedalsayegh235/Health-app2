import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/controllers/animation/appointment_animation.dart';
import 'package:health/controllers/appointment_controller.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/appointment/appointment_card.dart';
import 'package:health/patient_views/tabs/widgets/appointment/appointment_header.dart';
import 'package:health/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AppointmentTab extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppointmentTab({Key? key, this.scaffoldKey}) : super(key: key);

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AppointmentController _appointmentController;
  late AppointmentAnimations _animations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _appointmentController = AppointmentController();
    _animations = AppointmentAnimations(this);

    // Start animations when the tab is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animations.start();
    });

    // Listen for tab changes to restart animations
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _animations.reset();
        Future.delayed(const Duration(milliseconds: 100), () {
          _animations.start();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentController.dispose();
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ChangeNotifierProvider.value(
      value: _appointmentController,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(isDarkMode),
        body: Column(
          children: [
            // Animated header
            SlideTransition(
              position: _animations.headerSlideAnimation,
              child: FadeTransition(
                opacity: _animations.fadeAnimation,
                child: AppointmentHeader(
                  isDark: isDarkMode,
                  tabController: _tabController,
                  scaffoldKey: widget.scaffoldKey ?? GlobalKey<ScaffoldState>(),
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: FadeTransition(
                opacity: _animations.listFadeAnimation,
                child: SlideTransition(
                  position: _animations.listSlideAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentList("available", isDarkMode),
                      _buildAppointmentList("mine", isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(String type, bool isDarkMode) {
    return Consumer<AppointmentController>(
      builder: (context, controller, child) {
        final user = Provider.of<UserProvider>(context).user;

        return StreamBuilder<QuerySnapshot>(
          stream: controller.appointmentsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(isDarkMode, snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(isDarkMode);
            }

            List<DocumentSnapshot> docs;
            if (type == "available") {
              docs = controller.filterAvailableAppointments(
                snapshot.data!.docs,
              );
            } else {
              docs = controller.filterUserAppointments(
                snapshot.data!.docs,
                user?.id ?? '',
              );
            }

            if (docs.isEmpty) {
              return _buildEmptyState(type, isDarkMode);
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Trigger a rebuild by calling setState
                setState(() {});
              },
              color: AppTheme.lightgreen,
              backgroundColor: AppTheme.cardColor(isDarkMode),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 80),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final doctorId = data['doctorId'];

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: controller.getDoctorInfo(doctorId),
                    builder: (context, doctorSnap) {
                      String doctorName = '';
                      if (doctorSnap.hasData && doctorSnap.data != null) {
                        doctorName = doctorSnap.data!['name'] ?? '';
                      }

                      return AppointmentCard(
                        appointment: doc,
                        doctorName: doctorName,
                        type: type,
                        isDarkMode: isDarkMode,
                        index: index,
                        onRequest: type == "available"
                            ? () => _requestAppointment(
                                doctorId,
                                doc.id,
                                isDarkMode,
                              )
                            : null,
                        onCancel:
                            type == "mine" && (data['status'] == 'pending')
                            ? () => _cancelAppointment(
                                doctorId,
                                doc.id,
                                isDarkMode,
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            );
          },
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

  Widget _buildErrorState(bool isDarkMode, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Icon(Icons.error_outline, color: Colors.red, size: 48),
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightgreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type, bool isDarkMode) {
    final isAvailable = type == "available";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.cardGradient(isDarkMode),
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Icon(
              isAvailable ? Icons.event_busy : Icons.calendar_today,
              color: AppTheme.lightgreen,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isAvailable ? 'No Available Appointments' : 'No Appointments Yet',
            style: TextStyle(
              color: AppTheme.textColor(isDarkMode),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAvailable
                ? 'Check back later for new appointments'
                : 'Your requested appointments will appear here',
            style: TextStyle(
              color: AppTheme.textSecondaryColor(isDarkMode),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (isAvailable) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {}); // Refresh
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightgreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestAppointment(
    String doctorId,
    String appointmentId,
    bool isDarkMode,
  ) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    final confirmed = await _appointmentController.showConfirmationDialog(
      context: context,
      title: 'Request Appointment',
      content:
          'Do you want to request this appointment? The doctor will need to approve your request.',
      confirmText: 'Request',
      isDarkMode: isDarkMode,
    );

    if (!confirmed) return;

    final success = await _appointmentController.requestAppointment(
      doctorId,
      appointmentId,
      user.id!,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Appointment requested successfully!',
        AppTheme.lightgreen,
        Icons.check_circle,
      );
    } else {
      _showSnackBar(
        'Failed to request appointment. Please try again.',
        Colors.red,
        Icons.error,
      );
    }
  }

  Future<void> _cancelAppointment(
    String doctorId,
    String appointmentId,
    bool isDarkMode,
  ) async {
    final confirmed = await _appointmentController.showConfirmationDialog(
      context: context,
      title: 'Cancel Appointment',
      content: 'Are you sure you want to cancel this appointment request?',
      confirmText: 'Cancel',
      isDarkMode: isDarkMode,
    );

    if (!confirmed) return;

    final success = await _appointmentController.cancelAppointment(
      doctorId,
      appointmentId,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Appointment cancelled successfully!',
        AppTheme.lightgreen,
        Icons.check_circle,
      );
    } else {
      _showSnackBar(
        'Failed to cancel appointment. Please try again.',
        Colors.red,
        Icons.error,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
