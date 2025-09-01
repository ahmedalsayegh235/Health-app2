import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/Reading.dart';


class ReadingDetailDialog extends StatefulWidget {
  final String title;
  final HealthReading reading;
  final bool isDark;
  final String unit;
  final Color color;

  const ReadingDetailDialog({
    super.key,
    required this.title,
    required this.reading,
    required this.isDark,
    required this.unit,
    required this.color,
  });

  @override
  State<ReadingDetailDialog> createState() => _ReadingDetailDialogState();
}

class _ReadingDetailDialogState extends State<ReadingDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
            child: Center(
              child: Transform.translate(
                offset: Offset(0, 50 * _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppTheme.cardGradient(widget.isDark),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildMainContent(),
                        _buildDetailGraph(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withValues(alpha: 0.2),
            widget.color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
              color: widget.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),
              color: widget.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.title} Reading',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                ),
                Text(
                  _formatDateTime(widget.reading.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor(widget.isDark),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _closeDialog,
            icon: Icon(
              Icons.close,
              color: AppTheme.textSecondaryColor(widget.isDark),
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.textSecondaryColor(widget.isDark).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main Reading Value
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withValues(alpha: 0.1),
                  widget.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${_formatValue(widget.reading.value)}${widget.unit}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.reading.note,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor(widget.isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Additional Info
          _buildInfoRow('Time: ', _formatTime(widget.reading.timestamp)),
          const SizedBox(height: 8),
          _buildInfoRow('Date: ', _formatDate(widget.reading.timestamp)),
          const SizedBox(height: 8),
          _buildInfoRow('Status: ', widget.reading.note),
        ],
      ),
    );
  }

Widget _buildInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 80, // fixed width for labels to align neatly
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor(widget.isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor(widget.isDark),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildDetailGraph() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Analysis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: widget.color.withValues(alpha: 0.2),
                      strokeWidth: 0.5,
                      dashArray: [2, 2],
                    );
                  },
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: widget.reading.value - (widget.reading.value * 0.2),
                maxY: widget.reading.value + (widget.reading.value * 0.2),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateTrendData(),
                    isCurved: true,
                    color: widget.color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: widget.color,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withValues(alpha: 0.3),
                          widget.color.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                // Share reading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading shared successfully!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _closeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
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
    );
  }

  IconData _getIcon() {
    switch (widget.title.toLowerCase()) {
      case 'heart rate':
        return Icons.favorite;
      case 'spo2':
        return Icons.air;
      case 'ecg':
        return Icons.monitor_heart;
      default:
        return Icons.health_and_safety;
    }
  }

  String _formatValue(double value) {
    if (widget.title.toLowerCase() == 'ecg') {
      return (value).toStringAsFixed(2);
    }
    return value.toStringAsFixed(0);
  }

  Color _getStatusColor() {
    switch (widget.title.toLowerCase()) {
      case 'heart rate':
        if (widget.reading.value < 60 || widget.reading.value > 100) {
          return Colors.orange;
        }
        return AppTheme.lightgreen;
      case 'spo2':
        if (widget.reading.value < 95) return Colors.orange;
        return AppTheme.lightgreen;
      case 'ecg':
        return AppTheme.lightgreen;
      default:
        return AppTheme.lightgreen;
    }
  }

  String _getStatusText() {
    switch (widget.title.toLowerCase()) {
      case 'heart rate':
        if (widget.reading.value < 60) return 'BELOW NORMAL';
        if (widget.reading.value > 100) return 'ABOVE NORMAL';
        return 'NORMAL';
      case 'spo2':
        if (widget.reading.value < 90) return 'LOW';
        if (widget.reading.value < 95) return 'FAIR';
        return 'EXCELLENT';
      case 'ecg':
        return 'NORMAL RHYTHM';
      default:
        return 'NORMAL';
    }
  }

  List<FlSpot> _generateTrendData() {
    // Generate sample trend data around the current reading
    final baseValue = widget.reading.value;
    return [
      FlSpot(0, baseValue * 0.95),
      FlSpot(1, baseValue * 0.98),
      FlSpot(2, baseValue * 1.02),
      FlSpot(3, baseValue * 0.97),
      FlSpot(4, baseValue * 1.01),
      FlSpot(5, baseValue * 0.99),
      FlSpot(6, baseValue),
    ];
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}