import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Gradient? gradient;
  final Color backgroundColor;

  const ScoreBar({
    super.key,
    required this.animation,
    this.width = 60,
    this.height = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.gradient,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            alignment: Alignment.centerLeft,
            child: Container(
              width: width * animation.value,
              height: height,
              decoration: BoxDecoration(
                gradient: gradient ??
                    const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF1DE9B6)],
                    ),
                borderRadius: borderRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}
