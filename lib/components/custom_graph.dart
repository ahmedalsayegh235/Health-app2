import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/models/Reading.dart';
import '../../../helpers/app_theme.dart';

class CustomHealthGraph extends StatelessWidget {
  final List<HealthReading> readings;
  final String unit;
  final bool isDark;
  final Color? lineColor;
  final bool showDots;
  final bool isCurved;
  final double lineWidth;
  final String title;

  const CustomHealthGraph({
    super.key,
    required this.readings,
    required this.unit,
    required this.isDark,
    this.lineColor,
    this.showDots = true,
    this.isCurved = true,
    this.lineWidth = 3,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Title Row ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title Graph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(isDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lineColor?.withValues(alpha: 0.1) ??
                      AppTheme.lightgreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'All readings',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: lineColor ?? AppTheme.lightgreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ---- Chart ----
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getHorizontalInterval(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textSecondaryColor(isDark)
                          .withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  // ---- X Axis (time) ----
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: readings.length > 5 ? readings.length / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= readings.length) {
                          return const SizedBox.shrink();
                        }
                        final reading = readings[index];
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _formatTime(reading.timestamp),
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor(isDark),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ---- Y Axis (values) ----
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _getVerticalInterval(),
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${value.toInt()}$unit',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor(isDark),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (readings.length - 1).toDouble(),
                minY: _getMinY(),
                maxY: _getMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(),
                    isCurved: isCurved,
                    color: lineColor ?? AppTheme.lightgreen,
                    barWidth: lineWidth,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showDots,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor ?? AppTheme.lightgreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          (lineColor ?? AppTheme.lightgreen)
                              .withValues(alpha: 0.3),
                          (lineColor ?? AppTheme.lightgreen)
                              .withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],

                // ---- Tooltips ----
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        AppTheme.cardColor(isDark), // replaces tooltipBgColor
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final reading = readings[barSpot.x.toInt()];
                        return LineTooltipItem(
                          '${reading.value}$unit\n${reading.note}',
                          TextStyle(
                            color: AppTheme.textColor(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Empty state ----
  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradient(isDark),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart,
                size: 48, color: AppTheme.textSecondaryColor(isDark)),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording to see your $title data',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---- Helpers ----
  List<FlSpot> _getSpots() {
    return readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  double _getMinY() {
    if (readings.isEmpty) return 0;
    final values = readings.map((r) => r.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    return (min - (min * 0.1)).clamp(0, double.infinity);
  }

  double _getMaxY() {
    if (readings.isEmpty) return 100;
    final values = readings.map((r) => r.value).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    return max + (max * 0.1);
  }

  double _getHorizontalInterval() {
    final range = _getMaxY() - _getMinY();
    return range / 5;
  }

  double _getVerticalInterval() {
    final range = _getMaxY() - _getMinY();
    return range / 4;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}