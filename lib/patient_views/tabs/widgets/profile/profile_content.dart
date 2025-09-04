import 'package:flutter/material.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_text_formfield.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/user_model.dart';
import 'package:health/patient_views/tabs/widgets/profile/profile_picture_profile.dart';
import 'package:health/patient_views/tabs/widgets/profile/readonlyfield_profile.dart';

class ProfileContent extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final Animation<double>? fadeAnimation;
  final Animation<Offset>? slideAnimation;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final bool isSaving;
  final Future<void> Function(UserModel user) onSave;

  const ProfileContent({
    super.key,
    required this.user,
    required this.isDark,
    this.fadeAnimation,
    this.slideAnimation,
    required this.nameController,
    required this.emailController,
    required this.formKey,
    this.isSaving = false,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomScrollView(
      slivers: [
        // Header with profile picture
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 40, bottom: 30),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Centered title
                Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ProfilePicture(
                  scaleAnimation: fadeAnimation,
                  imagePath: 'assets/images/placeholderdog.png',
                  size: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name ?? 'User Name',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role ?? 'User',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Form content
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor(isDark),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: nameController,
                      hintText: "Full Name",
                      prefixIcon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "Enter your name" : null,
                    ),
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "Email Address",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val!.isEmpty) return "Enter your email";
                        if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                            .hasMatch(val.trim())) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      controller: nameController,
                      hintText: "Full Name",
                      prefixIcon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ReadOnlyField(
                      label: "CPR",
                      value: user.cpr ?? "Not provided",
                      icon: Icons.credit_card,
                    ),
                    ReadOnlyField(
                      label: "Gender",
                      value: user.gender ?? "Not specified",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      onPressed: () => onSave(user),
                      text: "Save Changes",
                      isLoading: isSaving,
                      gradientColors: const [
                        AppTheme.lightgreen,
                        AppTheme.darkgreen,
                      ],
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkgreen.withValues(alpha:0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Apply optional fade/slide animations
    if (fadeAnimation != null && slideAnimation != null) {
      return FadeTransition(
        opacity: fadeAnimation!,
        child: SlideTransition(
          position: slideAnimation!,
          child: content,
        ),
      );
    }

    return content;
  }
}
