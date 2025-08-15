import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.height = 56,
    this.width = double.infinity,
    this.borderRadius,
    this.gradientColors,
    this.textStyle,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final shadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ??
              [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: radius,
        boxShadow: shadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    gradientColors != null
                        ? gradientColors![0]
                        : Colors.green,
                  ),
                ),
              )
            : Text(
                text,
                style: textStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gradientColors != null
                          ? gradientColors![0]
                          : Colors.green,
                      letterSpacing: 0.5,
                    ),
              ),
      ),
    );
  }
}
