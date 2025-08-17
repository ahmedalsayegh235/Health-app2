import 'package:flutter/material.dart';
import 'package:health/components/custom_header_button.dart';
import 'package:health/controllers/animation/auth_animation_controller.dart';
import 'package:health/views/auth_view/widgets/animated_auth_form.dart';
import 'package:health/views/auth_view/widgets/animated_background.dart';
import 'package:health/views/auth_view/widgets/auth_switch_link.dart';
import 'package:provider/provider.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/custom_text_formfield.dart';
import 'package:health/components/custom_dropdown_menu.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/theme_provider.dart';
import '../../controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final AuthController _authController = AuthController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cprController = TextEditingController();
  String _selectedGender = "Male"; // default gender
  bool _isLoading = false;
  String? _errorMessage;
  late AuthAnimationController _authAnimationController;

  @override
  void initState() {
    super.initState();
    _authAnimationController = AuthAnimationController(vsync: this);
    _authAnimationController.startAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _cprController.dispose();
    _authAnimationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final user = await _authController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
      name: _nameController.text.trim(),
      cpr: _cprController.text.trim(),
      gender: _selectedGender,
    );

    if (user != null) {
      // Start exit animation before navigating to home
      await _authAnimationController.exitController.forward();
      Navigator.pushReplacementNamed(context, 'home');
    }
  } catch (e) {
    // Display validation or Firebase errors
    setState(() => _errorMessage = e.toString().replaceAll("Exception: ", ""));
  } finally {
    setState(() => _isLoading = false);
  }
}

  void _toggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      body: Stack(
        children: [
          // Background with floating medical icons
          AnimatedBackground(
            backgroundController: _authAnimationController.backgroundController,
            isDarkMode: isDarkMode,
          ),

          // Theme toggle button
          Positioned(
            top: 30,
            right: 20,
            child: HeaderButton(
              icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
              onTap: _toggleTheme,
              iconColor: AppTheme.textColor(isDarkMode),
              iconSize: 24,
              padding: const EdgeInsets.all(12),
              backgroundColor: AppTheme.cardColor(isDarkMode),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Animated signup form
          AnimatedAuthForm(
            slideController: _authAnimationController.slideController,
            exitController: _authAnimationController.exitController,
            formFade: _authAnimationController.formFade,
            isDarkMode: isDarkMode,
            heightFactor: 0.85,
            logo: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/splash_screen_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: "Create Account",
            subtitle: "Sign up to start your wellness journey",
            errorMessage: _errorMessage,
            fields: [
              CustomTextFormField(
                controller: _nameController,
                hintText: "Full Name",
                prefixIcon: Icons.person_outline,
              ),
              CustomTextFormField(
                controller: _emailController,
                hintText: "Email Address",
                prefixIcon: Icons.email_outlined,
              ),
              CustomTextFormField(
                controller: _cprController,
                hintText: "CPR Number",
                digitsOnly: true,
                prefixIcon: Icons.badge_outlined,
              ),
              CustomDropdownFormField<String>(
                value: _selectedGender,
                items: ["Male", "Female", "Other"]
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
                hintText: "Gender",
              ),
              CustomTextFormField(
                controller: _passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              CustomTextFormField(
                controller: _confirmPasswordController,
                hintText: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
            actionButton: CustomButton(
              onPressed: _isLoading ? null : _signUp,
              text: "Sign Up",
              isLoading: _isLoading,
            ),
            bottomWidget: [
              const SizedBox(height: 25),
              AuthLinkRow(
                leadingText: "Already have an account?",
                actionText: "Sign In",
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'login');
                },
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}