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
    with TickerProviderStateMixin {
  late AnimationController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1a1a1a) : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Medical Grid Background
          CustomPaint(
            painter: MedicalGridPainter(
              isDark: widget.isDark,
              animationValue: _scrollController.value,
            ),
            size: Size.infinite,
          ),
          // ECG Waveform
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 8, top: 8, bottom: 30),
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
            color: Colors.green.withValues(alpha: .5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Place fingers on sensors',
            style: TextStyle(
              color: Colors.green.withValues(alpha: .7),
              fontSize: 12,
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
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 4),
            Text(
              'REC ${(widget.recordingProgress! * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIndicator() {
    return Positioned(
      top: 8,
      left: 8,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.ecgData.isNotEmpty ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.ecgData.isNotEmpty ? 'Signal OK' : 'No Signal',
            style: TextStyle(
              color: widget.ecgData.isNotEmpty ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _createECGChartData() {
    if (widget.ecgData.isEmpty) {
      return LineChartData(lineBarsData: []);
    }

    final spots = <FlSpot>[];
    final dataLength = widget.ecgData.length;
    final maxPoints = 300; // Limit points for better performance
    final step = dataLength > maxPoints ? dataLength ~/ maxPoints : 1;
    
    for (int i = 0; i < dataLength; i += step) {
      if (i < widget.ecgData.length) {
        final timePoint = i / 250.0; // 250Hz sample rate
        spots.add(FlSpot(timePoint, widget.ecgData[i]));
      }
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
          isCurved: false,
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
    if (samples.isEmpty) {
      return _buildNoDataIndicator();
    }

    final sampleRate = widget.ecgReading.sampleRate;
    final totalDuration = widget.ecgReading.duration;

    return Column(
      children: [
        _buildChartHeader(),
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1a1a1a) : Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha:0.3)),
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
                padding: const EdgeInsets.only(left: 50, right: 15, top: 15, bottom: 40),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(widget.isDark),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                ),
                Text(
                  '${widget.ecgReading.calculatedHeartRate?.toInt() ?? '--'} BPM • '
                  '${widget.ecgReading.duration.toInt()}s • '
                  '${(widget.ecgReading.signalQuality * 100).toInt()}% Quality',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getQualityColor().withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(widget.ecgReading.signalQuality * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
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
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
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
    final maxScroll = totalDuration - _viewWindowSeconds;
    
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
                  color: AppTheme.textSecondaryColor(widget.isDark),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _currentScrollPosition,
                  min: 0,
                  max: maxScroll > 0 ? maxScroll : 0.1,
                  divisions: maxScroll > 0 ? (maxScroll * 4).toInt() : 1,
                  activeColor: Colors.green,
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
                  color: AppTheme.textSecondaryColor(widget.isDark),
                ),
              ),
            ],
          ),
          Text(
            'Viewing: ${_currentScrollPosition.toStringAsFixed(1)}s - ${(_currentScrollPosition + _viewWindowSeconds).toStringAsFixed(1)}s',
            style: TextStyle(
              fontSize: 10,
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
      minY: -3.0, // -3mV
      maxY: 3.0,  // +3mV
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

// Custom Painters for ECG Grid and Axis Labels
class MedicalGridPainter extends CustomPainter {
  final bool isDark;
  final double animationValue;

  MedicalGridPainter({required this.isDark, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.3)
      ..strokeWidth = 1.0;

    final minorPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.1)
      ..strokeWidth = 0.5;

    // Vertical grid lines (time - 0.2s major, 0.04s minor)
    final majorVSpacing = size.width / 10; // 2 seconds / 10 = 0.2s intervals
    for (int i = 0; i <= 10; i++) {
      final x = i * majorVSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
      
      // Minor vertical lines
      if (i < 10) {
        for (int j = 1; j < 5; j++) {
          final minorX = x + (j * majorVSpacing / 5);
          canvas.drawLine(Offset(minorX, 0), Offset(minorX, size.height), minorPaint);
        }
      }
    }

    // Horizontal grid lines (amplitude - 1mV major, 0.2mV minor)
    final majorHSpacing = size.height / 6; // 6mV total range / 6 = 1mV intervals
    for (int i = 0; i <= 6; i++) {
      final y = i * majorHSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
      
      // Minor horizontal lines
      if (i < 6) {
        for (int j = 1; j < 5; j++) {
          final minorY = y + (j * majorHSpacing / 5);
          canvas.drawLine(Offset(0, minorY), Offset(size.width, minorY), minorPaint);
        }
      }
    }

    // Moving sweep line for real-time effect
    final sweepPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.6)
      ..strokeWidth = 2.0;
    
    final sweepX = (animationValue * size.width) % size.width;
    canvas.drawLine(
      Offset(sweepX, 0),
      Offset(sweepX, size.height),
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(MedicalGridPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class DetailedMedicalGridPainter extends CustomPainter {
  final bool isDark;

  DetailedMedicalGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final majorPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.4)
      ..strokeWidth = 1.0;

    final minorPaint = Paint()
      ..color = Colors.green.withValues(alpha:0.2)
      ..strokeWidth = 0.5;

    // Vertical lines (0.2s major intervals)
    final majorVSpacing = size.width / 20; // 4 seconds / 20 = 0.2s
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

    // Horizontal lines (1mV major intervals)
    final majorHSpacing = size.height / 6; // 6mV range / 6 = 1mV
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

    // Y-axis labels (mV)
    final amplitudes = [3, 2, 1, 0, -1, -2, -3];
    for (int i = 0; i < amplitudes.length; i++) {
      textPainter.text = TextSpan(
        text: '${amplitudes[i]}mV',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      final y = (i * size.height / (amplitudes.length - 1)) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(2, y));
    }

    // X-axis labels (time)
    final timeLabels = ['0s', '0.5s', '1s', '1.5s', '2s'];
    for (int i = 0; i < timeLabels.length; i++) {
      textPainter.text = TextSpan(
        text: timeLabels[i],
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      final x = 40 + (i * (size.width - 48) / (timeLabels.length - 1)) - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x, size.height - 20));
    }
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

    // Y-axis labels (mV)
    final amplitudes = [3, 2, 1, 0, -1, -2, -3];
    for (int i = 0; i < amplitudes.length; i++) {
      textPainter.text = TextSpan(
        text: '${amplitudes[i]}mV',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      final y = (i * size.height / (amplitudes.length - 1)) - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(5, y));
    }

    // X-axis labels (time) - dynamic based on scroll position
    for (int i = 0; i <= 4; i++) {
      final time = scrollPosition + (i * viewWindow / 4);
      textPainter.text = TextSpan(
        text: '${time.toStringAsFixed(1)}s',
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      final x = 50 + (i * (size.width - 65) / 4) - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x, size.height - 25));
    }
  }

  @override
  bool shouldRepaint(DetailedAxisLabelPainter oldDelegate) {
    return oldDelegate.scrollPosition != scrollPosition;
  }
}