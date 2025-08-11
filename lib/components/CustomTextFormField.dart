import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function()? onSend;
  final bool showSendIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool digitsOnly; // 👈 New flag to allow numeric-only

  const CustomTextFormField({
    Key? key,
    required this.controller,
    this.hintText = "Write a comment...",
    this.maxLines = 4,
    this.onChanged,
    this.onSend,
    this.showSendIcon = false,
    this.validator,
    required this.obscureText,
    this.digitsOnly = false, // default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              validator: validator,
              controller: controller,
              maxLines: maxLines,
              obscureText: obscureText,
              onChanged: onChanged,
              keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
              inputFormatters: digitsOnly
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: theme.hintColor),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          if (showSendIcon && onSend != null)
            IconButton(
              icon: Icon(Icons.send_rounded, color: theme.primaryColor),
              onPressed: onSend,
              tooltip: "Send",
            ),
        ],
      ),
    );
  }
}
