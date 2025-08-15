import 'package:flutter/material.dart';

class HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  const HeaderButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.iconSize = 20,
    this.margin = const EdgeInsets.only(left: 8),
    this.padding = const EdgeInsets.all(10),
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: .1),
          borderRadius: borderRadius,
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
