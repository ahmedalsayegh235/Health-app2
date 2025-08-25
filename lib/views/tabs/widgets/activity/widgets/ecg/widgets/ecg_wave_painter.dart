import 'package:flutter/material.dart';

class ECGWavePainter extends CustomPainter {
  final List<double> waveData;
  final double animationValue;
  final Color color;

  ECGWavePainter({
    required this.waveData,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw grid
    final gridSpacing = 20.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (waveData.isEmpty) return;

    final path = Path();
    final centerY = size.height / 2;
    final scaleX = size.width / waveData.length;
    final scaleY = size.height / 4;

    // Calculate which part of the wave to show based on animation
    final visiblePoints = (waveData.length * animationValue).ceil();

    for (int i = 0; i < visiblePoints && i < waveData.length; i++) {
      final x = i * scaleX;
      final y = centerY - (waveData[i] * scaleY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw current position indicator
    if (visiblePoints < waveData.length) {
      final currentX = visiblePoints * scaleX;
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX, size.height),
        Paint()
          ..color = color.withValues(alpha: .7)
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(ECGWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
    oldDelegate.waveData != waveData;
  }
}
