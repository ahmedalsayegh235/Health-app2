import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/user_provider.dart';
import '../../helpers/theme_provider.dart';

class DrAppointmentTab extends StatefulWidget {
  const DrAppointmentTab({Key? key}) : super(key: key);

  @override
  State<DrAppointmentTab> createState() => _DrAppointmentTabState();
}

class _DrAppointmentTabState extends State<DrAppointmentTab> {
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<void> _acceptAppointment(String doctorId, String appointmentId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .collection('appointments')
        .doc(appointmentId);

    final snap = await docRef.get();
    final data = snap.data() as Map<String, dynamic>;
    final patientId = data['patientId'];

    String patientName = "";
    if (patientId != null) {
      final patientSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get();
      if (patientSnap.exists) {
        patientName = patientSnap['name'] ?? "";
      }
    }

    await docRef.update({
      'status': 'booked',
      'patientName': patientName, // save it here
    });
  }

  Future<void> _showCreateDialog(String doctorId, bool isDarkMode) async {
    DateTime? startTime;
    DateTime? endTime;
    String? selectedPatientId;
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // prevent dismiss by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickStartTime() async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final chosen = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {
                    startTime = chosen;
                    endTime = chosen.add(const Duration(hours: 1));
                  });
                }
              }
            }

            Future<void> pickEndTime() async {
              final date = await showDatePicker(
                context: context,
                initialDate: startTime ?? DateTime.now(),
                firstDate: startTime ?? DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final chosen = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                  setState(() {
                    endTime = chosen;
                  });
                }
              }
            }

            return AlertDialog(
              backgroundColor: AppTheme.cardColor(isDarkMode),
              title: Text(
                "Create Appointment",
                style: TextStyle(color: AppTheme.textColor(isDarkMode)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        startTime == null
                            ? "Choose start time"
                            : "Start: ${dateFormat.format(startTime!)}",
                        style: TextStyle(color: AppTheme.textColor(isDarkMode)),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: isSaving ? null : pickStartTime,
                    ),
                    ListTile(
                      title: Text(
                        endTime == null
                            ? "Choose end time"
                            : "End: ${dateFormat.format(endTime!)}",
                        style: TextStyle(color: AppTheme.textColor(isDarkMode)),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: isSaving ? null : pickEndTime,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Assign to Patient (optional)",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'patient')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final patients = snapshot.data!.docs;
                        return DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: AppTheme.cardColor(isDarkMode),
                          value: selectedPatientId,
                          hint: Text(
                            "Select patient",
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor(isDarkMode),
                            ),
                          ),
                          items: patients.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                data['name'] ?? 'Unnamed',
                                style: TextStyle(
                                  color: AppTheme.textColor(isDarkMode),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedPatientId = value;
                                  });
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
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
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (startTime == null || endTime == null) return;

                          setState(() => isSaving = true);

                          final docRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(doctorId)
                              .collection('appointments')
                              .doc();

                          await docRef.set({
                            'doctorId': doctorId,
                            'startTime': Timestamp.fromDate(startTime!.toUtc()),
                            'endTime': Timestamp.fromDate(endTime!.toUtc()),
                            'status': selectedPatientId == null
                                ? 'available'
                                : 'booked',
                            if (selectedPatientId != null)
                              'patientId': selectedPatientId,
                          });

                          if (context.mounted) Navigator.pop(context);
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No appointments"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final startTime = (data['startTime'] as Timestamp).toDate();
            final endTime = (data['endTime'] as Timestamp).toDate();
            final patientId = data['patientId'];

            return FutureBuilder<DocumentSnapshot>(
              future: patientId != null
                  ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(patientId)
                        .get()
                  : null,
              builder: (context, patientSnap) {
                String patientName = "";
                if (patientSnap.hasData && patientSnap.data!.exists) {
                  final pdata =
                      patientSnap.data!.data() as Map<String, dynamic>;
                  patientName = pdata['name'] ?? "";
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
                      "${dateFormat.format(startTime)} → ${dateFormat.format(endTime)}",
                      style: TextStyle(
                        color: AppTheme.textColor(isDarkMode),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Status: $status${patientName.isNotEmpty ? "\nPatient: $patientName" : ""}",
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor(isDarkMode),
                      ),
                    ),
                    trailing: status == "pending"
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightgreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                _acceptAppointment(doctorId, doc.id),
                            child: const Text("Accept"),
                          )
                        : Icon(
                            status == "available"
                                ? Icons.event_available
                                : Icons.check_circle,
                            color: status == "available"
                                ? Colors.green
                                : Colors.blue,
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
    final user = Provider.of<UserProvider>(context).user;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: AppTheme.cardColor(isDarkMode),
                child: TabBar(
                  labelColor: AppTheme.lightgreen,
                  unselectedLabelColor: AppTheme.textSecondaryColor(isDarkMode),
                  indicatorColor: AppTheme.lightgreen,
                  tabs: const [
                    Tab(text: "Available"),
                    Tab(text: "Pending"),
                    Tab(text: "Booked"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAppointmentList(user!.id!, isDarkMode, "available"),
                    _buildAppointmentList(user.id!, isDarkMode, "pending"),
                    _buildAppointmentList(user.id!, isDarkMode, "booked"),
                  ],
                ),
              ),
            ],
          ),
          // Floating Add Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppTheme.lightgreen,
              onPressed: () => _showCreateDialog(user.id!, isDarkMode),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
