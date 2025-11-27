import 'package:flutter/material.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/ecg/previous_reading_ecg.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/ecg/realtime_ecg.dart';
import 'package:provider/provider.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';
import 'package:health/controllers/sensor_provider.dart';
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
  late AnimationController _heartbeatController;
  Stream<List<HealthReading>>? _ecgReadingsStream;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize stream once and cache it
    _ecgReadingsStream ??= Provider.of<SensorProvider>(context, listen: false).ecgStream();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    final provider = Provider.of<SensorProvider>(context, listen: false);

    if (provider.isEcgRecording) {
      provider.stopEcgRecording();
      _pulseController.stop();
      _pulseController.reset();

      // Show health status dialog after a short delay to allow reading to be saved
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final lastReading = provider.lastEcgReading;
          if (lastReading != null) {
            _showHealthStatusDialog(lastReading);
          }
        }
      });
    } else {
      // Check if in ECG mode
      if (!provider.isEcgMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Please switch to ECG mode on your device first'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      provider.startCollection('ecg');
      _pulseController.repeat(reverse: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.fiber_manual_record, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('ECG recording started - Stay still for 30 seconds'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showHealthStatusDialog(HealthReading reading) {
    final ecgHeartRate = reading.value;
    final rhythm = reading.rhythmClassification;

    // Determine if medical attention is needed based on heart rate or rhythm
    final requiresAttention = requiresECGMedicalAttention(ecgHeartRate) ||
                               requiresECGRhythmMedicalAttention(rhythm);

    final category = getECGHeartRateCategory(ecgHeartRate);
    final riskLevel = getECGHeartRateRiskLevel(ecgHeartRate);
    final heartRateAdvice = getECGHeartRateAdvice(ecgHeartRate);
    final rhythmAdvice = getECGRhythmAdvice(rhythm);
    final combinedAdvice = '$heartRateAdvice\n\nRhythm Analysis: $rhythmAdvice';
    final statusColor = getECGHeartRateStatusColor(ecgHeartRate);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HealthStatusDialog(
        title: 'ECG Reading',
        value: ecgHeartRate.toInt().toString(),
        unit: 'bpm',
        category: '$category | $rhythm',
        riskLevel: riskLevel,
        message: combinedAdvice,
        statusColor: statusColor,
        icon: Icons.monitor_heart,
        requiresMedicalAttention: requiresAttention,
        isDark: widget.isDark,
        onBookAppointment: () {
          Navigator.of(context).pop();
          // Navigate to appointment tab
          DefaultTabController.of(context).animateTo(2);
        },
        onDismiss: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showReadingDetail(HealthReading reading) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.cardGradient(widget.isDark),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.2),
                      Colors.green.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.monitor_heart,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ECG Recording',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor(widget.isDark),
                            ),
                          ),
                          Text(
                            formatTime(reading.timestamp),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor(widget.isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textSecondaryColor(widget.isDark),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ECG Chart
                      if (reading.ecgSamples.isNotEmpty) ...[
                        DetailedECGChart(
                          ecgReading: reading,
                          isDark: widget.isDark,
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'ECG waveform data not available for this recording.',
                                  style: TextStyle(
                                    color: AppTheme.textColor(widget.isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Metrics
                      Text(
                        'Analysis Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow('Heart Rate', '${reading.value.toInt()} BPM'),
                      _buildMetricRow('Rhythm', reading.rhythmClassification),
                      _buildMetricRow('QRS Count', '${reading.qrsCount}'),
                      _buildMetricRow('Signal Quality', '${(reading.signalQuality * 100).toInt()}%'),
                      _buildMetricRow('Duration', '${reading.duration.toStringAsFixed(1)}s'),
                      if (reading.note.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor(widget.isDark),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reading.note,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor(widget.isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor(widget.isDark),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getRhythmFromReading(HealthReading reading) {
    if (reading.metadata != null && reading.metadata!['rhythm'] != null) {
      return reading.metadata!['rhythm'].toString();
    }
    
    final note = reading.note;
    final rhythmMatch = RegExp(r'Rhythm: ([^|]+)').firstMatch(note);
    return rhythmMatch?.group(1)?.trim() ?? 'Unknown';
  }

  int _getQrsCountFromReading(HealthReading reading) {
    if (reading.metadata != null && reading.metadata!['qrsCount'] != null) {
      return (reading.metadata!['qrsCount'] as num).toInt();
    }
    
    final note = reading.note;
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

  Color _getRhythmColor(String rhythm) {
    switch (rhythm) {
      case 'Normal Sinus Rhythm':
        return Colors.green;
      case 'Bradycardia':
      case 'Tachycardia':
        return Colors.orange;
      case 'Irregular Rhythm':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        final isRecording = provider.isEcgRecording;
        final currentReading = provider.lastEcgReading;
        final isEcgMode = provider.isEcgMode;
        final realtimeBPM = provider.realtimeBPM;
        final realtimeRhythm = provider.realtimeRhythm;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Mode Indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isEcgMode 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEcgMode ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEcgMode ? Icons.check_circle : Icons.info,
                      color: isEcgMode ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEcgMode
                            ? 'Device in ECG mode - Ready to record'
                            : 'Switch device to ECG mode to start recording',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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

                    // Status Display
                    if (isEcgMode && !isRecording) ...[
                      // Real-time monitoring display
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          if (realtimeBPM > 0) {
                            // Trigger heartbeat animation
                            if (!_heartbeatController.isAnimating) {
                              _heartbeatController.repeat();
                            }
                          }
                          return Transform.scale(
                            scale: realtimeBPM > 0 ? _pulseAnimation.value : 1.0,
                            child: Icon(
                              Icons.monitor_heart,
                              size: 48,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (realtimeBPM > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  realtimeBPM.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor(widget.isDark),
                                  ),
                                ),
                                Text(
                                  'BPM',
                                  style: TextStyle(
                                    fontSize: 13,
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getRhythmColor(realtimeRhythm).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getRhythmColor(realtimeRhythm).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            realtimeRhythm,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getRhythmColor(realtimeRhythm),
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Monitoring...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryColor(widget.isDark),
                          ),
                        ),
                      ],
                    ] else if (isRecording) ...[
                      // Recording status
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Icon(
                              Icons.fiber_manual_record,
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
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stay still and breathe normally',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: provider.ecgRecordingProgress,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(provider.ecgRecordingProgress * 30).toInt()}s / 30s',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ] else ...[
                      // Not in ECG mode
                      Icon(
                        Icons.monitor_heart_outlined,
                        size: 48,
                        color: AppTheme.textSecondaryColor(widget.isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Switch to ECG Mode',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Press the button on your device',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Record/Stop Button
                    CustomButton(
                      onPressed: _toggleRecording,
                      text: isRecording ? 'Stop Recording' : 'Start 30s Recording',
                      isLoading: false,
                      height: 52,
                      gradientColors: isRecording
                          ? [Colors.red, Colors.redAccent]
                          : isEcgMode
                              ? [Colors.green, Colors.lightGreen]
                              : [Colors.grey, Colors.grey[600]!],
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    if (!isEcgMode && !isRecording)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Recording disabled - Switch device mode',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Latest Reading Metrics (from last recording, not real-time)
              if (currentReading != null) ...[
                Text(
                  'Latest Recording',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                ),
                const SizedBox(height: 12),
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
                    Expanded(
                      child: ECGInfoCard(
                        title: 'Quality',
                        value: '${((currentReading.metadata?['signalQuality'] ?? 0) * 100).toInt()}%',
                        icon: Icons.signal_cellular_alt,
                        color: Colors.purple,
                        isDark: widget.isDark,
                      ),
                    ),
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
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Medical Disclaimer: This device is for wellness tracking only. '
                        'ECG readings should not replace professional medical advice, '
                        'diagnosis, or treatment. Consult a healthcare provider for medical concerns.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Previous Readings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Previous Readings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor(widget.isDark),
                    ),
                  ),
                  if (!_showAllReadings)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAllReadings = true;
                        });
                      },
                      icon: Icon(Icons.expand_more, size: 18, color: Colors.green),
                      label: Text(
                        'Show All',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<HealthReading>>(
                stream: _ecgReadingsStream,
                builder: (context, snapshot) {
                  // Show loading only on initial load
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.monitor_heart_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No previous ECG recordings',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor(widget.isDark),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your first recording above',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor(widget.isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final readings = snapshot.data!;
                  final displayReadings = _showAllReadings ? readings : readings.take(5);

                  return Column(
                    children: [
                      ...displayReadings.map((reading) => Padding(
                            key: ValueKey(reading.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EcgReadingCard(
                              reading: reading,
                              isDark: widget.isDark,
                              onTap: _showReadingDetail,
                              formatTime: formatTime,
                            ),
                          )),
                      if (readings.length > 5 && _showAllReadings)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showAllReadings = false;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.expand_less, color: Colors.green),
                              Text(
                                "Show Less",
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
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