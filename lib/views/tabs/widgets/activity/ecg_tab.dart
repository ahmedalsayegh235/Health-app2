import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';
import 'package:health/views/tabs/widgets/activity/widgets/ecg/widgets/ecg_wave_painter.dart';
import 'package:health/views/tabs/widgets/activity/widgets/ecg/widgets/info_card.dart';
import 'package:health/views/tabs/widgets/activity/widgets/ecg/widgets/reading_card.dart';
import 'package:health/views/tabs/widgets/activity/widgets/reading_diaglog.dart';
import 'dart:math' as math;

class ECGTab extends StatefulWidget {
  final bool isDark;

  const ECGTab({super.key, required this.isDark});

  @override
  State<ECGTab> createState() => _ECGTabState();
}

class _ECGTabState extends State<ECGTab> with TickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  List<HealthReading> _readings = [];
  List<double> _ecgWaveData = [];

  @override
  void initState() {
    super.initState();
    _generateSampleData();
    _generateECGWave();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateSampleData() {
    _readings = [
      HealthReading(
        timestamp: DateTime.now(),
        value: 0.8,
        note: 'Normal sinus rhythm',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        value: 0.7,
        note: 'Regular rhythm',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        value: 0.9,
        note: 'Slight irregularity detected',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        value: 0.8,
        note: 'Normal rhythm',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        value: 0.75,
        note: 'Healthy pattern',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        value: 0.85,
        note: 'Good rhythm',
      ),
      HealthReading(
        timestamp: DateTime.now().subtract(const Duration(hours: 24)),
        value: 0.8,
        note: 'Normal',
      ),
    ];
  }

  void _generateECGWave() {
    _ecgWaveData.clear();
    for (int i = 0; i < 200; i++) {
      double x = i / 20.0;
      double y = 0;

      // Generate ECG-like waveform
      if (x % 1.0 < 0.1) {
        // QRS complex
        y = math.sin(x * 100) * 0.8;
      } else if (x % 1.0 < 0.3) {
        // T wave
        y = math.sin(x * 10) * 0.2;
      } else {
        // Baseline with small variations
        y = math.sin(x * 5) * 0.05;
      }

      _ecgWaveData.add(y);
    }
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _waveController.repeat();
      _pulseController.repeat(reverse: true);

      // Simulate recording for 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          _stopRecording();
        }
      });
    } else {
      _waveController.stop();
      _pulseController.stop();
    }
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    _waveController.stop();
    _pulseController.stop();

    // Add new reading
    final newReading = HealthReading(
      timestamp: DateTime.now(),
      value: 0.7 + (0.3 * (DateTime.now().millisecond % 10) / 10),
      note: 'Just recorded',
    );

    setState(() {
      _readings.insert(0, newReading);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ECG recorded successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showReadingDetail(HealthReading reading) {
    showDialog(
      context: context,
      builder: (context) => ReadingDetailDialog(
        title: 'ECG',
        reading: reading,
        isDark: widget.isDark,
        unit: 'mV',
        color: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentReading = _readings.isNotEmpty ? _readings.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Reading Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.1),
                  Colors.lightGreen.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // ECG Wave Display
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: _isRecording
                      ? AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: ECGWavePainter(
                                waveData: _ecgWaveData,
                                animationValue: _waveAnimation.value,
                                color: Colors.green,
                              ),
                              size: Size.infinite,
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.show_chart,
                                color: Colors.green.withValues(alpha: 0.5),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Place fingers on sensors',
                                style: TextStyle(
                                  color: Colors.green.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                if (currentReading != null && !_isRecording) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0,
                        child: Icon(
                          Icons.monitor_heart,
                          size: 48,
                          color: Colors.green,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(currentReading.value * 100).toInt()} mV',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor(widget.isDark),
                    ),
                  ),
                  Text(
                    'Peak Amplitude',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor(widget.isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentReading.note,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor(widget.isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_isRecording) ...[
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.monitor_heart,
                          size: 48,
                          color: Colors.green,
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
                  Text(
                    'Hold still for 30 seconds',
                    style: TextStyle(
                      fontSize: 14,
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
                    '-- mV',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor(widget.isDark),
                    ),
                  ),
                  Text(
                    'Peak Amplitude',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor(widget.isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                CustomButton(
                  onPressed: _toggleRecording,
                  text: _isRecording ? 'Stop Recording' : 'Start ECG Recording',
                  isLoading: false,
                  height: 50,
                  gradientColors: _isRecording
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

          // Info Cards
          Row(
            children: [
              Expanded(
                child: ECGInfoCard(
                  title: 'Heart Rate',
                  value: '89 BPM',
                  icon: Icons.favorite,
                  color: Colors.red,
                  isDark: widget.isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ECGInfoCard(
                  title: 'Rhythm',
                  value: 'Normal',
                  icon: Icons.graphic_eq,
                  color: Colors.green,
                  isDark: widget.isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Warning Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ECG readings are for wellness purposes only and should not be used for medical diagnosis.',
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

          // Graph Section (simplified for ECG)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.cardGradient(widget.isDark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: widget.isDark ? 0.3 : 0.1,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ECG History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'ECG Pattern Analysis\n(Requires multiple readings)',
                      style: TextStyle(
                        color: Colors.green.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Previous Readings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Previous Readings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(widget.isDark),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all readings
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppTheme.lightgreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Readings List
          ..._readings
              .take(5)
              .map(
                (reading) => ECGReadingCard(
                  reading: reading,
                  isDark: widget.isDark, // pass the current theme mode
                  onTap: (r) {
                    // Handle reading tap, e.g., show details
                    _showReadingDetail(reading);
                  },
                ),
              ),
        ],
      ),
    );
  }
}
