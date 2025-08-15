import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/app_theme.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function()? onSend;
  final bool showSendIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool digitsOnly;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.hintText = "Enter text",
    this.maxLines = 1,
    this.onChanged,
    this.onSend,
    this.showSendIcon = false,
    this.validator,
    this.obscureText = false,
    this.digitsOnly = false,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  IconData _getDefaultPrefixIcon() {
    if (widget.hintText.toLowerCase().contains('email')) {
      return Icons.email_outlined;
    } else if (widget.hintText.toLowerCase().contains('password')) {
      return Icons.lock_outline;
    } else if (widget.hintText.toLowerCase().contains('name')) {
      return Icons.person_outline;
    } else {
      return Icons.text_fields_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1), // softer shadow like your _buildTextField
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        maxLines: widget.maxLines,
        obscureText: widget.obscureText ? _isObscured : false,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType ??
            (widget.digitsOnly
                ? TextInputType.number
                : widget.hintText.toLowerCase().contains('email')
                    ? TextInputType.emailAddress
                    : TextInputType.text),
        inputFormatters:
            widget.digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : [],
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D5A3D),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppTheme.darkgreen.withValues(alpha: .6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            widget.prefixIcon ?? _getDefaultPrefixIcon(),
            color: AppTheme.darkgreen.withValues(alpha: .7),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.darkgreen.withValues(alpha: .7),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : widget.showSendIcon && widget.onSend != null
                  ? IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppTheme.darkgreen,
                      ),
                      onPressed: widget.onSend,
                    )
                  : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: .9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.darkgreen,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
