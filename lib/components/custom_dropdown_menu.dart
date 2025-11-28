import 'package:flutter/material.dart';
import '../helpers/app_theme.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String hintText;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const CustomDropdownFormField({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText = "Select an option",
    this.validator,
    this.prefixIcon,
  });

  IconData _getDefaultPrefixIcon() {
    if (hintText.toLowerCase().contains('gender')) {
      return Icons.person_outline;
    } else if (hintText.toLowerCase().contains('role')) {
      return Icons.badge_outlined;
    } else {
      return Icons.arrow_drop_down_circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        color: Colors.white.withOpacity(0.9),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppTheme.darkgreen.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon ?? _getDefaultPrefixIcon(),
            color: AppTheme.darkgreen.withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.darkgreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.darkgreen.withOpacity(0.7),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D5A3D),
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white.withOpacity(0.95),
      ),
    );
  }
}
