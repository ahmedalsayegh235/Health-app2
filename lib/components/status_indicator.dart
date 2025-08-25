import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const StatusIndicator({
    super.key,
    this.color = const Color(0xFF00E676), // default green
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
