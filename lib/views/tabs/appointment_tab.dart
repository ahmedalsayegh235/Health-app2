import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentTab extends StatefulWidget {
  const AppointmentTab({Key? key}) : super(key: key);

  @override
  State<AppointmentTab> createState() => _AppointmentTabState();
}

class _AppointmentTabState extends State<AppointmentTab> {
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<void> _requestAppointment(
    String doctorId,
    String appointmentId,
    bool isDarkMode,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor(isDarkMode),
          title: Text(
            "Request Appointment",
            style: TextStyle(color: AppTheme.textColor(isDarkMode)),
          ),
          content: const Text("Do you want to request this appointment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppTheme.lightgreen),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightgreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Request"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final user = Provider.of<UserProvider>(context, listen: false).user;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .collection('appointments')
        .doc(appointmentId);

    await docRef.update({'status': 'pending', 'patientId': user!.id});
  }

  Widget _buildAppointmentList(
    Stream<QuerySnapshot> stream,
    bool isDarkMode,
    String type,
  ) {
    final user = Provider.of<UserProvider>(context).user;

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('heeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
          return const Center(child: Text("Something went wrong"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? "available";
          final patientId = data['patientId'];

          if (type == "available") {
            return status == "available";
          } else {
            return patientId == user!.id &&
                (status == "pending" || status == "booked");
          }
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Text(
              type == "available"
                  ? "No available appointments"
                  : "You have no appointments",
              style: TextStyle(color: AppTheme.textColor(isDarkMode)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final startTime = (data['startTime'] as Timestamp).toDate();
            final endTime = (data['endTime'] as Timestamp).toDate();
            final status = data['status'] ?? "available";
            final doctorId = data['doctorId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(doctorId)
                  .get(),
              builder: (context, doctorSnap) {
                String doctorName = "";
                if (doctorSnap.hasData && doctorSnap.data!.exists) {
                  final ddata = doctorSnap.data!.data() as Map<String, dynamic>;
                  doctorName = ddata['name'] ?? "";
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.cardGradient(isDarkMode),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      "$doctorName\n${dateFormat.format(startTime)} → ${dateFormat.format(endTime)}",
                      style: TextStyle(
                        color: AppTheme.textColor(isDarkMode),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Status: $status",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor(isDarkMode),
                      ),
                    ),
                    trailing: type == "available"
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightgreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _requestAppointment(
                              doctorId,
                              doc.id,
                              isDarkMode,
                            ),
                            child: const Text("Request"),
                          )
                        : Icon(
                            status == "booked"
                                ? Icons.check_circle
                                : Icons.hourglass_top,
                            color: status == "booked"
                                ? Colors.blue
                                : Colors.orange,
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final appointmentsStream = FirebaseFirestore.instance.collectionGroup(
      'appointments',
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Appointments"),
          backgroundColor: AppTheme.darkgreen,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Available"),
              Tab(text: "My Appointments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList(
              appointmentsStream.snapshots(),
              isDarkMode,
              "available",
            ),
            _buildAppointmentList(
              appointmentsStream.snapshots(),
              isDarkMode,
              "mine",
            ),
          ],
        ),
      ),
    );
  }
}
