import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:health/helpers/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final DocumentSnapshot appointment;
  final String doctorName;
  final String type;
  final bool isDarkMode;
  final VoidCallback? onRequest;
  final VoidCallback? onCancel;
  final int index;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.doctorName,
    required this.type,
    required this.isDarkMode,
    this.onRequest,
    this.onCancel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final data = appointment.data() as Map<String, dynamic>;
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final status = data['status'] ?? "available";
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.cardGradient(isDarkMode),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: .1) 
                : Colors.grey.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: type == "available" ? onRequest : null,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with doctor name and status
                    Row(
                      children: [
                        // Doctor avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.lightgreen.withValues(alpha:0.8),
                                AppTheme.darkgreen.withValues(alpha:0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha:0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName.isNotEmpty ? doctorName : 'Dr. Unknown',
                                style: TextStyle(
                                  color: AppTheme.textColor(isDarkMode),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getSpecialty(data),
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor(isDarkMode),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Date and time information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withValues(alpha:0.05) 
                            : Colors.grey.withValues(alpha:0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withValues(alpha:0.1) 
                              : Colors.grey.withValues(alpha:0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppTheme.lightgreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(startTime),
                                  style: TextStyle(
                                    color: AppTheme.textColor(isDarkMode),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: ${_getDuration(startTime, endTime)}',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor(isDarkMode),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    if (type == "available" || status == "pending") ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (type == "available") ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onRequest,
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: const Text('Request'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.lightgreen,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: AppTheme.lightgreen.withValues(alpha:0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ] else if (status == "pending") ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onCancel,
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'available':
        color = const Color(0xFF4ECDC4);
        icon = Icons.event_available;
        break;
      case 'pending':
        color = const Color(0xFFFFB74D);
        icon = Icons.hourglass_top;
        break;
      case 'booked':
        color = const Color(0xFF66BB6A);
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.capitalize(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getSpecialty(Map<String, dynamic> data) {
    // You can extend this to get actual specialty from doctor data
    return data['specialty'] ?? 'General Practice';
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}