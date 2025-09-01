import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_text_formfield.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/user_model.dart';


Future<void> showPasswordDialog({
  required BuildContext context,
  required UserModel user,
  required Future<void> Function(UserModel user, String password) onConfirm,
}) async {
  final passwordController = TextEditingController();
  bool isLoading = false;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              content: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.cardGradient(Theme.of(context).brightness == Brightness.dark),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkgreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightgreen.withValues(alpha: 0.2),
                            AppTheme.darkgreen.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.security,
                        size: 32,
                        color: AppTheme.darkgreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Security Verification',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(Theme.of(context).brightness == Brightness.dark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your current password to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor(Theme.of(context).brightness == Brightness.dark),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextFormField(
                      controller: passwordController,
                      hintText: "Current Password",
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: (val) => val!.isEmpty ? "Enter your current password" : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                            text: "Cancel",
                            gradientColors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (passwordController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please enter your password")),
                                      );
                                      return;
                                    }

                                    setDialogState(() => isLoading = true);

                                    try {
                                      await onConfirm(user, passwordController.text.trim());
                                      Navigator.of(dialogContext).pop();
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Error: ${e.toString()}")),
                                      );
                                    } finally {
                                      setDialogState(() => isLoading = false);
                                    }
                                  },
                            text: "Confirm",
                            isLoading: isLoading,
                            gradientColors: const [
                              AppTheme.lightgreen,
                              AppTheme.darkgreen,
                            ],
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
