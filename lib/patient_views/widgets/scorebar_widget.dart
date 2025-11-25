import 'package:flutter/material.dart';


class ScoreBar extends StatelessWidget {
  /// The animation controller for the score bar
  final Animation<double> animation;
  
  /// The health score to display (0-100)
  final int score;
  
  /// Optional custom color for the progress bar
  final Color? color;
  
  /// Height of the score bar
  final double height;

  const ScoreBar({
    super.key,
    required this.animation,
    this.score = 100,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate the target progress based on score
        final targetProgress = score / 100.0;
        
        // Apply animation to the progress
        // The animation value goes from 0.0 to 1.0
        // We multiply by target progress to get the animated fill
        final animatedProgress = (targetProgress * animation.value).clamp(0.0, 1.0);
        
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * animatedProgress;
              
              return Stack(
                children: [
                  // Animated progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: barWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: color != null
                            ? _getColorGradient(color!)
                            : _getGradientColors(score),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: (color ?? _getGradientColors(score)[0])
                              .withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Generate gradient colors based on a base color
  List<Color> _getColorGradient(Color baseColor) {
    // For green-based colors (good health), use white gradient for visibility
    if (baseColor == Colors.green || baseColor == Colors.lightGreen) {
      return [Colors.white, Colors.white.withOpacity(0.8)];
    }
    // For other colors, create a subtle gradient
    return [baseColor, baseColor.withOpacity(0.7)];
  }

  /// Get gradient colors based on score value
  /// Higher scores = cooler (green/white), lower scores = warmer (red/orange)
  List<Color> _getGradientColors(int score) {
    if (score >= 90) {
      // Excellent - White gradient (visible on dark header)
      return [Colors.white, Colors.white.withOpacity(0.8)];
    } else if (score >= 75) {
      // Good - Light white/green
      return [Colors.white, Colors.white.withOpacity(0.9)];
    } else if (score >= 60) {
      // Fair - Orange gradient
      return [Colors.orange, Colors.amber];
    } else if (score >= 40) {
      // Poor - Deep orange gradient
      return [Colors.deepOrange, Colors.orange];
    } else {
      // Critical - Red gradient
      return [Colors.red, Colors.redAccent];
    }
  }
}

/// Alternative ScoreBar with more customization options
class ScoreBarAdvanced extends StatelessWidget {
  final Animation<double> animation;
  final int score;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showGlow;
  final bool showPercentage;

  const ScoreBarAdvanced({
    super.key,
    required this.animation,
    required this.score,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 8,
    this.borderRadius,
    this.showGlow = true,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);
    final bgColor = backgroundColor ?? Colors.white.withOpacity(0.2);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final targetProgress = score / 100.0;
        final animatedProgress = (targetProgress * animation.value).clamp(0.0, 1.0);
        final animatedScore = (score * animation.value).round();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPercentage)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$animatedScore%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: effectiveBorderRadius,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth * animatedProgress;
                  final fgColor = foregroundColor ?? _getScoreColor(score);
                  
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: barWidth,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [fgColor, fgColor.withOpacity(0.7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: effectiveBorderRadius,
                          boxShadow: showGlow
                              ? [
                                  BoxShadow(
                                    color: fgColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }
}

/// Circular Score Indicator Alternative
class CircularScoreIndicator extends StatelessWidget {
  final Animation<double> animation;
  final int score;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  const CircularScoreIndicator({
    super.key,
    required this.animation,
    required this.score,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedProgress = (score / 100.0 * animation.value).clamp(0.0, 1.0);
        final animatedScore = (score * animation.value).round();
        final fgColor = foregroundColor ?? _getScoreColor(score);
        
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    backgroundColor ?? Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              ),
              // Score text
              Text(
                '$animatedScore',
                style: textStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: size / 3,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }
}