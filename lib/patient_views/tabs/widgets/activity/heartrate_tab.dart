import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_graph.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/models/Reading.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/heart/reading_card.dart';
import 'package:health/patient_views/tabs/widgets/activity/widgets/reading_diaglog.dart';
import 'package:provider/provider.dart';

class HeartRateTab extends StatefulWidget {
  final bool isDark;

  const HeartRateTab({super.key, required this.isDark});

  @override
  State<HeartRateTab> createState() => _HeartRateTabState();
}

class _HeartRateTabState extends State<HeartRateTab>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _showAllReadings = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
    sensorProvider.startCollection('heart_rate');

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isRecording) {
        _stopRecording();
      }
    });
  }

Future<void> _stopRecording() async {
  if (!_isRecording) return;

  setState(() {
    _isRecording = false;
  });
  _pulseController.stop();
  _pulseController.reset();

  final sensorProvider = context.read<SensorProvider>();
  final lastReading = sensorProvider.lastHeartRate;

  if (lastReading != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Heart Rate recorded: ${lastReading.value.toInt()} bpm',
        ),
        backgroundColor: AppTheme.lightgreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final newActivity = {
  'title': 'Heart rate measured: ${lastReading.value.toInt()} bpm',
  'icon': "heart",            // will map to Icons.favorite
  'iconColor': 0xFFF44336,    // red
    };
    // Save using ActivityProvider
    final activityProvider = context.read<ActivityProvider>();
    await activityProvider.addActivity(newActivity);
  }
}


  void _showReadingDetail(HealthReading reading) {
    showDialog(
      context: context,
      builder: (context) => ReadingDetailDialog(
        title: 'Heart Rate',
        reading: reading,
        isDark: widget.isDark,
        unit: 'bpm',
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorProvider>();
    final userId = sensorProvider.userId;

    return StreamBuilder<List<HealthReading>>(
      stream: sensorProvider.heartRateStream(),
      builder: (context, snapshot) {
        // for testing the syream builder
        print("StreamBuilder state: ${snapshot.connectionState}");
        print("Has data: ${snapshot.hasData}");
        print("Data length: ${snapshot.data?.length ?? 0}");

        if (snapshot.hasError) {
          print("StreamBuilder error: ${snapshot.error}");
          return Center(
            child: Text(
              'Error loading readings: ${snapshot.error}',
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
                      Colors.red.withValues(alpha: 0.1),
                      Colors.pink.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
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
                                        Colors.red.withValues(alpha: 0.8),
                                        Colors.pink.withValues(alpha: 0.6),
                                      ]
                                    : [
                                        Colors.red.withValues(alpha: 0.2),
                                        Colors.pink.withValues(alpha: 0.1),
                                      ],
                              ),
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: 48,
                              color: _isRecording ? Colors.white : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (currentReading != null && !_isRecording) ...[
                      Text(
                        '${currentReading.value.toInt()}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                      Text(
                        'BPM',
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
                        'Recording...',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor(widget.isDark),
                        ),
                      ),
                      Text(
                        'Keep still',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '--',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      Text(
                        'BPM',
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
                      text: _isRecording ? 'Stop Recording' : 'Start Recording',
                      isLoading: false,
                      height: 50,
                      gradientColors: _isRecording
                          ? [Colors.red, Colors.pink]
                          : [
                              Colors.red.withValues(alpha: 0.8),
                              Colors.pink.withValues(alpha: 0.6),
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

              CustomHealthGraph(
                readings: readings,
                unit: 'bpm',
                isDark: widget.isDark,
                lineColor: Colors.red,
                title: 'Heart Rate',
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
                      setState(() {
                        _showAllReadings = !_showAllReadings;
                      });
                    },
                    child: Text(
                      _showAllReadings ? 'View Less' : "View All",
                      style: TextStyle(
                        color: AppTheme.lightgreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
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
                        Icons.favorite_border,
                        size: 48,
                        color: AppTheme.textSecondaryColor(widget.isDark),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userId == null
                            ? 'Login to view readings'
                            : 'No readings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondaryColor(widget.isDark),
                        ),
                      ),
                      if (userId != null)
                        Text(
                          'Start recording to see your heart rate data',
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
                getHeartStatusColor: getHeartStatusColor,
                getHeartStatusText: getHeartStatusText,
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
