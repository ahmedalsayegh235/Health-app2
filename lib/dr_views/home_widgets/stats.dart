import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/app_theme.dart';
import '../../controllers/user_provider.dart';
import 'package:provider/provider.dart';

class DrStatsGrid extends StatelessWidget {
  final bool isDarkMode;

  const DrStatsGrid({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final doctorId = user?.id ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .collection('appointments')
          .snapshots(),
      builder: (context, appointmentSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('members', arrayContains: doctorId)
              .where('isAccept', isEqualTo: true)
              .snapshots(),
          builder: (context, chatSnapshot) {
            // Calculate appointment stats
            Map<String, int> appointmentStats = {'available': 0, 'pending': 0, 'booked': 0};
            
            if (appointmentSnapshot.hasData) {
              for (var doc in appointmentSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'available';
                if (appointmentStats.containsKey(status)) {
                  appointmentStats[status] = appointmentStats[status]! + 1;
                }
              }
            }

            final int acceptedPatients = chatSnapshot.hasData ? chatSnapshot.data!.docs.length : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(isDarkMode),
                  ),
                ),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 20),
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _StatCard(
                      title: 'Available Slots',
                      value: appointmentStats['available'].toString(),
                      icon: Icons.schedule_outlined,
                      color: AppTheme.successColor,
                      isDarkMode: isDarkMode,
                    ),
                    _StatCard(
                      title: 'Pending Requests',
                      value: appointmentStats['pending'].toString(),
                      icon: Icons.pending_outlined,
                      color: AppTheme.warningColor,
                      isDarkMode: isDarkMode,
                    ),
                    _StatCard(
                      title: 'Booked Sessions',
                      value: appointmentStats['booked'].toString(),
                      icon: Icons.event_busy_outlined,
                      color: AppTheme.infoColor,
                      isDarkMode: isDarkMode,
                    ),
                    _StatCard(
                      title: 'Active Patients',
                      value: acceptedPatients.toString(),
                      icon: Icons.people_outline,
                      color: AppTheme.lightgreen,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(isDarkMode),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: AppTheme.textSecondaryColor(isDarkMode),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(isDarkMode),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}