import 'package:flutter/material.dart';


class AuthLinkRow extends StatelessWidget {
  final String leadingText; 
  final String actionText; 
  final VoidCallback onTap;
  final bool isDarkMode;

  const AuthLinkRow({
    Key? key,
    required this.leadingText,
    required this.actionText,
    required this.onTap,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          leadingText,
          style: TextStyle(
            color:Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
