import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:health/helpers/app_theme.dart';

class DrAppointmentCard extends StatelessWidget {
  final DocumentSnapshot appointment;
  final String patientName;
  final String status;
  final bool isDarkMode;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final int index;

  const DrAppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
    required this.status,
    required this.isDarkMode,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final data = appointment.data() as Map<String, dynamic>;
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final notes = data['notes'] as String?;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final isUpcoming = startTime.isAfter(now);
    final isPast = endTime.isBefore(now);

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
            colors: _getCardGradient(),
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
                ? Colors.white.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with time and status
                  Row(
                    children: [
                      // Time info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: _getStatusColor(),
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormat.format(startTime),
                              style: TextStyle(
                                color: _getStatusColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Date and duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(startTime),
                              style: TextStyle(
                                color: AppTheme.textColor(isDarkMode),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${timeFormat.format(startTime)} - ${timeFormat.format(endTime)}',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor(isDarkMode),
                                fontSize: 14,
                              ),
                            ),
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
                      
                      // Status and time indicator
                      Column(
                        children: [
                          _buildStatusChip(),
                          if (isPast) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PAST',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ] else if (isUpcoming && startTime.difference(now).inHours < 24) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SOON',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Patient information
                  if (patientName.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05) 
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.lightgreen.withOpacity(0.8),
                                  AppTheme.darkgreen.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientName,
                                  style: TextStyle(
                                    color: AppTheme.textColor(isDarkMode),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Patient',
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
                    const SizedBox(height: 16),
                  ],

                  // Notes section
                  if (notes != null && notes.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightgreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightgreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.note_alt,
                                color: AppTheme.lightgreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Notes',
                                style: TextStyle(
                                  color: AppTheme.textColor(isDarkMode),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor(isDarkMode),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Reject'),
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
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightgreen,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.lightgreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      case 'booked':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
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
        );
      case 'available':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
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
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusChip() {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4ECDC4);
      case 'pending':
        return const Color(0xFFFFB74D);
      case 'booked':
        return const Color(0xFF66BB6A);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.event_available;
      case 'pending':
        return Icons.hourglass_top;
      case 'booked':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<Color> _getCardGradient() {
    if (isDarkMode) {
      return [
        const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        const Color(0xFF16213E).withValues(alpha: 0.9),
      ];
    } else {
      return [Colors.white, const Color(0xFFF8F9FA)];
    }
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}