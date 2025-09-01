import 'package:flutter/material.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/ecg/previous_reading_ecg.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/ecg/realtime_ecg.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/reading_diaglog.dart';
import 'package:provider/provider.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';
import 'package:health/providers/sensor_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/ecg/widgets/info_card.dart';

class ECGTab extends StatefulWidget {
  final bool isDark;

  const ECGTab({super.key, required this.isDark});

  @override
  State<ECGTab> createState() => _ECGTabState();
}

class _ECGTabState extends State<ECGTab> with TickerProviderStateMixin {
  bool _showAllReadings = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    final provider = Provider.of<SensorProvider>(context, listen: false);
    
    if (provider.isEcgRecording) {
      provider.stopEcgRecording();
      _pulseController.stop();
    } else {
      provider.startCollection('ecg');
      _pulseController.repeat(reverse: true);
      
      // Show recording instruction
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ECG recording started. Stay still for 30 seconds.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showReadingDetail(HealthReading reading) {
    showDialog(
      context: context,
      builder: (context) => ReadingDetailDialog(
        title: 'ECG',
        reading: reading,
        isDark: widget.isDark,
        unit: 'bpm',
       
        color: Colors.green,
      ),
    );
  }

  String _getRhythmFromReading(HealthReading reading) {
    // Get rhythm from metadata if available, otherwise from note
    if (reading.metadata != null && reading.metadata!['rhythm'] != null) {
      return reading.metadata!['rhythm'].toString();
    }
    
    // Parse from note as fallback
    final note = reading.note ?? '';
    final rhythmMatch = RegExp(r'Rhythm: ([^|]+)').firstMatch(note);
    return rhythmMatch?.group(1)?.trim() ?? 'Unknown';
  }

  int _getQrsCountFromReading(HealthReading reading) {
    // Get QRS count from metadata if available, otherwise from note
    if (reading.metadata != null && reading.metadata!['qrsCount'] != null) {
      return (reading.metadata!['qrsCount'] as num).toInt();
    }
    
    // Parse from note as fallback
    final note = reading.note ?? '';
    final qrsMatch = RegExp(r'QRS count: (\d+)').firstMatch(note);
    return int.tryParse(qrsMatch?.group(1) ?? '0') ?? 0;
  }

  String _getRhythmShort(String fullRhythm) {
    switch (fullRhythm) {
      case 'Normal Sinus Rhythm':
        return 'Normal';
      case 'Bradycardia':
        return 'Slow';
      case 'Tachycardia':
        return 'Fast';
      case 'Irregular Rhythm':
        return 'Irregular';
      case 'Poor Signal Quality':
        return 'Poor Signal';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        final isRecording = provider.isEcgRecording;
        final currentReading = provider.lastEcgReading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main ECG Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.lightGreen.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Real-time ECG Chart
                    RealTimeECGChart(
                      ecgData: provider.realTimeEcgData,
                      isDark: widget.isDark,
                      isRecording: isRecording,
                      recordingProgress: isRecording ? provider.ecgRecordingProgress : null,
                    ),

                    const SizedBox(height: 20),

                    // Status and Metrics
                    if (currentReading != null && !isRecording) ...[
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Icon(
                            Icons.monitor_heart,
                            size: 48,
                            color: Colors.green,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                currentReading.value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor(widget.isDark),
                                ),
                              ),
                              Text(
                                'BPM',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor(widget.isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRhythmFromReading(currentReading),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ] else if (isRecording) ...[
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              Icons.monitor_heart,
                              size: 48,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recording ECG...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stay still and relaxed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: provider.ecgRecordingProgress,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(provider.ecgRecordingProgress * 30).toInt()}s / 30s',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.monitor_heart,
                        size: 48,
                        color: AppTheme.textSecondaryColor(widget.isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ready to Record',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Record Button
                    CustomButton(
                      onPressed: _toggleRecording,
                      text: isRecording ? 'Stop Recording' : 'Start ECG Recording',
                      isLoading: false,
                      height: 50,
                      gradientColors: isRecording
                          ? [Colors.red, Colors.redAccent]
                          : [Colors.green, Colors.lightGreen],
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Current Metrics Cards
              if (currentReading != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ECGInfoCard(
                        title: 'Heart Rate',
                        value: '${currentReading.value.toInt()} BPM',
                        icon: Icons.favorite,
                        color: Colors.red,
                        isDark: widget.isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ECGInfoCard(
                        title: 'Rhythm',
                        value: _getRhythmShort(_getRhythmFromReading(currentReading)),
                        icon: Icons.graphic_eq,
                        color: Colors.green,
                        isDark: widget.isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ECGInfoCard(
                        title: 'QRS Count',
                        value: '${_getQrsCountFromReading(currentReading)}',
                        icon: Icons.show_chart,
                        color: Colors.blue,
                        isDark: widget.isDark,
                      ),
                    ),
                    const SizedBox(width: 12), 
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Medical Disclaimer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This device is not a medical device. ECG readings are for wellness tracking only and should not replace professional medical advice.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Previous Readings
              StreamBuilder<List<HealthReading>>(
                stream: Provider.of<SensorProvider>(context, listen: false).ecgStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                      'No previous ECG readings available.',
                      style: TextStyle(color: AppTheme.textSecondaryColor(widget.isDark)),
                    );
                  }

                  final readings = snapshot.data!;
                  final displayReadings = _showAllReadings ? readings : readings.take(5);

                  return Column(
                    children: [
                      ...displayReadings.map((reading) => EcgReadingCard(
                            reading: reading,
                            isDark: widget.isDark,
                            onTap: _showReadingDetail,
                            formatTime: formatTime,
                          )),
                      if (readings.length > 5)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllReadings = !_showAllReadings;
                            });
                          },
                          child: Text(
                            _showAllReadings ? "Show Less" : "Show All",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}