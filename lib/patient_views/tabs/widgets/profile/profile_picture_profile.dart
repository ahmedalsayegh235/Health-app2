import 'package:flutter/material.dart';
import 'package:health/helpers/app_theme.dart';


class ProfilePicture extends StatelessWidget {
  final Animation<double>? scaleAnimation;
  final String imagePath;
  final double size;

  const ProfilePicture({
    Key? key,
    this.scaleAnimation,
    this.imagePath = 'assets/images/placeholderdog.png',
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.lightgreen.withValues(alpha: 0.3),
            AppTheme.darkgreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkgreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          if (scaleAnimation != null)
            BoxShadow(
              color: AppTheme.lightgreen.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: Image.asset(
            imagePath,
            width: size - 8,
            height: size - 8,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    if (scaleAnimation == null) return container;

    return AnimatedBuilder(
      animation: scaleAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation!.value,
          child: container,
        );
      },
    );
  }
}
