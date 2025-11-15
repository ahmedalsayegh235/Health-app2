import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final Animation<double> animation;
  final int score;
  final Color? color;

  const ScoreBar({
    super.key,
    required this.animation,
    this.score = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final targetProgress = score / 100.0;
        final animatedScore = (targetProgress * animation.value).clamp(0.0, 1.0);
        
        // DEBUG: i wanna see whats happening because it stops at 0.85
        print('Score: $score, Animation: ${animation.value}, Target: $targetProgress, Final: $animatedScore');
        
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animatedScore,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: color != null
                      ? _getColorGradient(color!)
                      : _getGradientColors(score),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? _getGradientColors(score)[0]).withValues(alpha:0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _getColorGradient(Color baseColor) {
    if (baseColor == Colors.green || baseColor == Colors.lightGreen) {
      return [Colors.white, Colors.white.withValues(alpha:0.8)];
    }
    return [baseColor, baseColor.withValues(alpha:0.7)];
  }

  List<Color> _getGradientColors(int score) {
    if (score >= 90) {
      return [Colors.white, Colors.white.withValues(alpha:0.8)];
    } else if (score >= 75) {
      return [Colors.white, Colors.white.withValues(alpha:0.9)];
    } else if (score >= 60) {
      return [Colors.orange, Colors.amber];
    } else if (score >= 40) {
      return [Colors.deepOrange, Colors.orange];
    } else {
      return [Colors.red, Colors.redAccent];
    }
  }
}