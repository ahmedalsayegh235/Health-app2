import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_graph.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/models/Reading.dart';
import 'package:health/providers/sensor_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/reading_diaglog.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/spo2/reading_card.dart';
import 'package:provider/provider.dart';

class SpO2Tab extends StatefulWidget {
  final bool isDark;

  const SpO2Tab({super.key, required this.isDark});

  @override
  State<SpO2Tab> createState() => _SpO2TabState();
}

class _SpO2TabState extends State<SpO2Tab> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _showAllReadings = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.lightBlue)
        .animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
    });

    _pulseController.repeat(reverse: true);

    final sensorProvider = context.read<SensorProvider>();
    sensorProvider.startCollection('spo2');

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isRecording) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
    });
    _pulseController.stop();
    _pulseController.reset();

    final sensorProvider = context.read<SensorProvider>();
    final lastReading = sensorProvider.lastSpo2;

    if (lastReading != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SpO2 recorded: ${lastReading.value.toInt()}%'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showReadingDetail(HealthReading reading) {
    showDialog(
      context: context,
      builder: (context) => ReadingDetailDialog(
        title: 'SpO2',
        reading: reading,
        isDark: widget.isDark,
        unit: '%',
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorProvider>();
    final userId = sensorProvider.userId;

    return StreamBuilder<List<HealthReading>>(
      stream: sensorProvider.spo2Stream(),
      builder: (context, snapshot) {
        print("SpO2 StreamBuilder state: ${snapshot.connectionState}");
        print("SpO2 Has data: ${snapshot.hasData}");
        print("SpO2 Data length: ${snapshot.data?.length ?? 0}");

        if (snapshot.hasError) {
          print("SpO2 StreamBuilder error: ${snapshot.error}");
          return Center(
            child: Text(
              'Error loading SpO2 readings: ${snapshot.error}',
              style: TextStyle(color: AppTheme.textColor(widget.isDark)),
            ),
          );
        }

        final readings = snapshot.data ?? [];
        final currentReading = readings.isNotEmpty ? readings.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.lightBlue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRecording ? _pulseAnimation.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isRecording
                                    ? [
                                        _colorAnimation.value!.withValues(
                                          alpha: 0.8,
                                        ),
                                        Colors.lightBlue.withValues(alpha: 0.6),
                                      ]
                                    : [
                                        Colors.blue.withValues(alpha: 0.2),
                                        Colors.lightBlue.withValues(alpha: 0.1),
                                      ],
                              ),
                            ),
                            child: Icon(
                              Icons.air,
                              size: 48,
                              color: _isRecording ? Colors.white : Colors.blue,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (currentReading != null && !_isRecording) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${currentReading.value.toInt()}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor(widget.isDark),
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondaryColor(widget.isDark),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'SpO2',
                        style: TextStyle(
                          fontSize: 18,
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
                      ),
                    ] else if (_isRecording) ...[
                      Text(
                        'Measuring...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                      Text(
                        'Place finger on sensor',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '--',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondaryColor(widget.isDark),
                            ),
                          ),
                          Text(
                            '%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondaryColor(widget.isDark),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'SpO2',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: userId != null ? _startRecording : null,
                      text: _isRecording ? 'Stop Measuring' : 'Start Measuring',
                      isLoading: false,
                      height: 50,
                      gradientColors: _isRecording
                          ? [Colors.blue, Colors.lightBlue]
                          : [
                              Colors.blue.withValues(alpha: 0.8),
                              Colors.lightBlue.withValues(alpha: 0.6),
                            ],
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (userId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Login required for recording',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor(widget.isDark),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Normal SpO2 levels are 95-100%. Values below 90% may require medical attention.',
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

              CustomHealthGraph(
                readings: readings,
                unit: '%',
                isDark: widget.isDark,
                lineColor: Colors.blue,
                title: 'SpO2',
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Previous Readings (${readings.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor(widget.isDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAllReadings = !_showAllReadings;
                    },
                    child: Text(
                      _showAllReadings ? 'View Less' : 'View All',
                      style: TextStyle(
                        color: AppTheme.lightgreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (readings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.cardGradient(widget.isDark),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.air,
                        size: 48,
                        color: AppTheme.textSecondaryColor(widget.isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userId == null
                            ? 'Login to view readings'
                            : 'No SpO2 readings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      if (userId != null)
                        Text(
                          'Start measuring to see your SpO2 data',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor(widget.isDark),
                          ),
                        ),
                    ],
                  ),
                ),

              ...(_showAllReadings ? readings : readings.take(5)).map(
              (reading) => ReadingCard(
                reading: reading,
                isDark: widget.isDark,
                onTap: _showReadingDetail,
                getSPo2StatusColor: getSPo2StatusColor,
                getSPo2StatusText: getSPo2StatusText,
                formatTime: formatTime,
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}
