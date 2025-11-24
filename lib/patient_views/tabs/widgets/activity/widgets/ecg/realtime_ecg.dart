import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/models/Reading.dart';
import 'package:health/helpers/app_theme.dart';
import 'dart:math' as math;

class RealTimeECGChart extends StatefulWidget {
  final List<double> ecgData;
  final bool isDark;
  final bool isRecording;
  final double? recordingProgress;

  const RealTimeECGChart({
    super.key,
    required this.ecgData,
    required this.isDark,
    this.isRecording = false,
    this.recordingProgress,
  });

  @override
  State<RealTimeECGChart> createState() => _RealTimeECGChartState();
}

class _RealTimeECGChartState extends State<RealTimeECGChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() {
        if (widget.ecgData.isNotEmpty) {
          setState(() {
            _scrollOffset += 0.01;
          });
        }
      });
    _scrollController.repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1a1a1a) : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Medical Grid Background
          CustomPaint(
            painter: MedicalGridPainter(
              isDark: widget.isDark,
              scrollOffset: _scrollOffset,
            ),
            size: Size.infinite,
          ),
          // ECG Waveform
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 8, top: 12, bottom: 35),
            child: widget.ecgData.isEmpty
                ? _buildNoSignalIndicator()
                : LineChart(_createECGChartData()),
          ),
          // Axis Labels
          _buildAxisLabels(),
          // Recording Progress Indicator
          if (widget.isRecording && widget.recordingProgress != null)
            _buildRecordingProgress(),
          // Signal Quality Indicator
          _buildSignalIndicator(),
        ],
      ),
    );
  }

  Widget _buildNoSignalIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            color: Colors.green.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for ECG signal...',
            style: TextStyle(
              color: Colors.green.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Switch to ECG mode on device',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabels() {
    return Positioned.fill(
      child: CustomPaint(
        painter: AxisLabelPainter(isDark: widget.isDark),
      ),
    );
  }

  Widget _buildRecordingProgress() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'REC ${(widget.recordingProgress! * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIndicator() {
    final hasSignal = widget.ecgData.isNotEmpty;
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (hasSignal ? Colors.green : Colors.grey).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSignal ? Colors.green : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hasSignal ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              hasSignal ? 'Signal OK' : 'No Signal',
              style: TextStyle(
                color: hasSignal ? Colors.green : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createECGChartData() {
    if (widget.ecgData.isEmpty) {
      return LineChartData(lineBarsData: []);
    }

    final spots = <FlSpot>[];
    final dataLength = widget.ecgData.length;
    
    // Use all data points for smooth rendering
    for (int i = 0; i < dataLength; i++) {
      final timePoint = i / 250.0; // 250Hz sample rate
      spots.add(FlSpot(timePoint, widget.ecgData[i]));
    }

    return LineChartData(
      clipData: const FlClipData.all(),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: spots.isNotEmpty ? spots.first.x : 0,
      maxX: spots.isNotEmpty ? spots.last.x : 2.0,
      minY: -3.0, // -3mV
      maxY: 3.0,  // +3mV
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false, // Sharp edges for medical accuracy
          color: Colors.green,
          barWidth: 2.0,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}

class DetailedECGChart extends StatefulWidget {
  final HealthReading ecgReading;
  final bool isDark;
  final double? scrollPosition;

  const DetailedECGChart({
    super.key,
    required this.ecgReading,
    required this.isDark,
    this.scrollPosition,
  });

  @override
  State<DetailedECGChart> createState() => _DetailedECGChartState();
}

class _DetailedECGChartState extends State<DetailedECGChart> {
  double _currentScrollPosition = 0.0;
  final double _viewWindowSeconds = 4.0;

  @override
  void initState() {
    super.initState();
    _currentScrollPosition = widget.scrollPosition ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final samples = widget.ecgReading.ecgSamples;
    final totalDuration = widget.ecgReading.duration;

    if (samples.isEmpty || totalDuration <= 0) {
      return _buildNoDataIndicator();
    }

    return Column(
      children: [
        _buildChartHeader(),
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1a1a1a) : Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              // Medical Grid
              CustomPaint(
                painter: DetailedMedicalGridPainter(isDark: widget.isDark),
                size: Size.infinite,
              ),
              // ECG Waveform
              Padding(
                padding: const EdgeInsets.only(left: 55, right: 15, top: 20, bottom: 45),
                child: LineChart(_createDetailedChartData()),
              ),
              // Axis Labels
              _buildDetailedAxisLabels(),
            ],
          ),
        ),
        // Scroll Control
        if (totalDuration > _viewWindowSeconds)
          _buildScrollControl(totalDuration),
      ],
    );
  }

  Widget _buildChartHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(widget.isDark),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lead I - ${widget.ecgReading.rhythmClassification}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.ecgReading.calculatedHeartRate?.toInt() ?? '--'} BPM • '
                  '${widget.ecgReading.duration.toInt()}s • '
                  '${(widget.ecgReading.signalQuality * 100).toInt()}% Quality',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getQualityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getQualityColor(), width: 1.5),
            ),
            child: Text(
              '${(widget.ecgReading.signalQuality * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getQualityColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor() {
    final quality = widget.ecgReading.signalQuality;
    if (quality >= 0.8) return Colors.green;
    if (quality >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildNoDataIndicator() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No ECG data available',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDetailedAxisLabels() {
    return Positioned.fill(
      child: CustomPaint(
        painter: DetailedAxisLabelPainter(
          isDark: widget.isDark,
          scrollPosition: _currentScrollPosition,
          viewWindow: _viewWindowSeconds,
        ),
      ),
    );
  }

  Widget _buildScrollControl(double totalDuration) {
    final maxScroll = math.max(0.0, totalDuration - _viewWindowSeconds);
    
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_currentScrollPosition.toStringAsFixed(1)}s',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor(widget.isDark),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _currentScrollPosition.clamp(0.0, maxScroll),
                  min: 0,
                  max: maxScroll > 0 ? maxScroll : 0.1,
                  divisions: maxScroll > 0 ? (maxScroll * 4).toInt() : 1,
                  activeColor: Colors.green,
                  inactiveColor: Colors.green.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      _currentScrollPosition = value;
                    });
                  },
                ),
              ),
              Text(
                '${totalDuration.toStringAsFixed(1)}s',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          Text(
            'Viewing: ${_currentScrollPosition.toStringAsFixed(1)}s - '
            '${math.min(_currentScrollPosition + _viewWindowSeconds, totalDuration).toStringAsFixed(1)}s',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryColor(widget.isDark),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _createDetailedChartData() {
    final samples = widget.ecgReading.ecgSamples;
    if (samples.isEmpty) return LineChartData(lineBarsData: []);

    final sampleRate = widget.ecgReading.sampleRate;
    final startSample = (_currentScrollPosition * sampleRate).toInt();
    final endSample = math.min(
      startSample + (_viewWindowSeconds * sampleRate).toInt(),
      samples.length,
    );

    final spots = <FlSpot>[];
    for (int i = startSample; i < endSample; i++) {
      final timePoint = i / sampleRate;
      spots.add(FlSpot(timePoint, samples[i]));
    }

    return LineChartData(
      clipData: const FlClipData.all(),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: _currentScrollPosition,
      maxX: _currentScrollPosition + _viewWindowSeconds,
      minY: -3.0,
      maxY: 3.0,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: Colors.green,
          barWidth: 2.0,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}

// Custom Painters
class MedicalGridPainter extends CustomPainter {
  final bool isDark;
  final double scrollOffset;

  MedicalGridPainter({required this.isDark, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..strokeWidth = 1.0;

    final minorPaint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Vertical grid lines
    final majorVSpacing = size.width / 10;
    for (int i = 0; i <= 10; i++) {
      final x = i * majorVSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
      
      if (i < 10) {
        for (int j = 1; j < 5; j++) {
          final minorX = x + (j * majorVSpacing / 5);
          canvas.drawLine(Offset(minorX, 0), Offset(minorX, size.height), minorPaint);
        }
      }
    }

    // Horizontal grid lines
    final majorHSpacing = size.height / 6;
    for (int i = 0; i <= 6; i++) {
      final y = i * majorHSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
      
      if (i < 6) {
        for (int j = 1; j < 5; j++) {
          final minorY = y + (j * majorHSpacing / 5);
          canvas.drawLine(Offset(0, minorY), Offset(size.width, minorY), minorPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(MedicalGridPainter oldDelegate) => true;
}

class DetailedMedicalGridPainter extends CustomPainter {
  final bool isDark;

  DetailedMedicalGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = Colors.green.withOpacity(0.4)
      ..strokeWidth = 1.0;

    final minorPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..strokeWidth = 0.5;

    final majorVSpacing = size.width / 20;
    for (int i = 0; i <= 20; i++) {
      final x = i * majorVSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
      
      if (i < 20) {
        for (int j = 1; j < 5; j++) {
          final minorX = x + (j * majorVSpacing / 5);
          canvas.drawLine(Offset(minorX, 0), Offset(minorX, size.height), minorPaint);
        }
      }
    }

    final majorHSpacing = size.height / 6;
    for (int i = 0; i <= 6; i++) {
      final y = i * majorHSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
      
      if (i < 6) {
        for (int j = 1; j < 5; j++) {
          final minorY = y + (j * majorHSpacing / 5);
          canvas.drawLine(Offset(0, minorY), Offset(size.width, minorY), minorPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DetailedMedicalGridPainter oldDelegate) => false;
}

class AxisLabelPainter extends CustomPainter {
  final bool isDark;

  AxisLabelPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textColor = Colors.white70;

    // Y-axis labels
    final amplitudes = [3, 2, 1, 0, -1, -2, -3];
    for (int i = 0; i < amplitudes.length; i++) {
      textPainter.text = TextSpan(
        text: '${amplitudes[i]}mV',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final y = (i * size.height / (amplitudes.length - 1)) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(2, y));
    }

    // X-axis label
    textPainter.text = TextSpan(
      text: 'Time (s)',
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 60, size.height - 22));
  }

  @override
  bool shouldRepaint(AxisLabelPainter oldDelegate) => false;
}

class DetailedAxisLabelPainter extends CustomPainter {
  final bool isDark;
  final double scrollPosition;
  final double viewWindow;

  DetailedAxisLabelPainter({
    required this.isDark,
    required this.scrollPosition,
    required this.viewWindow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textColor = Colors.white70;

    // Y-axis labels
    final amplitudes = [3, 2, 1, 0, -1, -2, -3];
    for (int i = 0; i < amplitudes.length; i++) {
      textPainter.text = TextSpan(
        text: '${amplitudes[i]}mV',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final y = (i * size.height / (amplitudes.length - 1)) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(5, y));
    }

    // X-axis labels
    for (int i = 0; i <= 4; i++) {
      final time = scrollPosition + (i * viewWindow / 4);
      textPainter.text = TextSpan(
        text: '${time.toStringAsFixed(1)}s',
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final x = 55 + (i * (size.width - 70) / 4) - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x, size.height - 28));
    }
  }

  @override
  bool shouldRepaint(DetailedAxisLabelPainter oldDelegate) {
    return oldDelegate.scrollPosition != scrollPosition;
  }
}