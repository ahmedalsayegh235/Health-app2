// i also updated this beacuse youre using it in the sign up page

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    Key? key,
    required this.controller,
    this.hintText = "Write a comment...",
    this.maxLines = 1,
    this.onChanged,
    this.onSend,
    this.showSendIcon = false,
    this.validator,
    required this.obscureText,
    this.digitsOnly = false,
    this.prefixIcon,
    this.keyboardType,
  }) : super(key: key);

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
    } else if (widget.hintText.toLowerCase().contains('cpr')) {
      return Icons.badge_outlined;
    } else {
      return Icons.text_fields_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB6EAC7).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
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
              inputFormatters: widget.digitsOnly
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D5A3D),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF6B8E7B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  widget.prefixIcon ?? _getDefaultPrefixIcon(),
                  color: const Color(0xFFB6EAC7),
                  size: 22,
                ),
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFFB6EAC7),
                          size: 22,
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
                              color: Color(0xFFB6EAC7),
                            ),
                            onPressed: widget.onSend,
                            tooltip: "Send",
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFE57373),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE57373),
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFE57373),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFB6EAC7),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}