import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/app_theme.dart';
import '../../controllers/user_provider.dart';
import 'package:provider/provider.dart';

class DrNextAppointmentCard extends StatelessWidget {
  final bool isDarkMode;

  const DrNextAppointmentCard({super.key, required this.isDarkMode});

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dayLabel;
    if (appointmentDate == today) {
      dayLabel = 'Today';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dayLabel at $time';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final doctorId = user?.id ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor(isDarkMode),
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(doctorId)
              .collection('appointments')
              .where('status', isEqualTo: 'booked')
              .where('startTime', isGreaterThan: Timestamp.now())
              .orderBy('startTime')
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _NoAppointmentCard(isDarkMode: isDarkMode);
            }

            final appointment = snapshot.data!.docs.first;
            final data = appointment.data() as Map<String, dynamic>;
            final startTime = (data['startTime'] as Timestamp).toDate();
            final endTime = (data['endTime'] as Timestamp).toDate();
            final patientName = data['patientName'] ?? 'Unknown Patient';
            final type = data['type'] ?? 'Consultation';

            return Container(
              width: double.infinity,
              decoration: AppTheme.cardDecoration(isDarkMode),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightgreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: AppTheme.lightgreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor(isDarkMode),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.successColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Booked',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: AppTheme.textSecondaryColor(isDarkMode),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateTime(startTime),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor(isDarkMode),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${endTime.difference(startTime).inMinutes} min',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to appointment details or video call
                            },
                            style: AppTheme.primaryButtonStyle(isDarkMode),
                            child: const Text('Start Session'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Show reschedule options
                          },
                          style: AppTheme.secondaryButtonStyle(isDarkMode),
                          child: const Icon(Icons.schedule, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  final bool isDarkMode;

  const _NoAppointmentCard({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.cardDecoration(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppTheme.textSecondaryColor(isDarkMode),
            ),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Appointments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have a clear schedule ahead',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor(isDarkMode),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to create new appointment slots
              },
              style: AppTheme.primaryButtonStyle(isDarkMode),
              child: const Text('Create Availability'),
            ),
          ],
        ),
      ),
    );
  }
}