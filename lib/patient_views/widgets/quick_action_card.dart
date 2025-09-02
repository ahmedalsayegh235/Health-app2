import 'package:flutter/material.dart';
import '../../helpers/app_theme.dart';

class QuickActionCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale values based on screen width
    final padding = screenWidth * 0.05; // outer padding
    final iconContainerPadding = screenWidth * 0.03; // icon container
    final iconSize = screenWidth * 0.08; // icon size
    final fontSize = screenWidth * 0.029; // text size
    final spacing = screenWidth * 0.04; // spacing between icon and text
    final borderRadius = screenWidth * 0.05;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double scale = 1 - _controller.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.iconColor.withOpacity(widget.isDarkMode ? 0.1 : 0.05),
                    widget.iconColor.withOpacity(widget.isDarkMode ? 0.05 : 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: widget.iconColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconContainerPadding),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(borderRadius * 0.8),
                      border: Border.all(
                        color: widget.iconColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: iconSize),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor(widget.isDarkMode),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
