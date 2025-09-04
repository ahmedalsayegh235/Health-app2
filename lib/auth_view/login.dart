import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/animation/auth_animation_controller.dart';
import '../helpers/app_theme.dart';
import '../components/custom_text_formfield.dart';
import '../components/custom_button.dart';
import 'widgets/animated_background.dart';
import 'widgets/animated_auth_form.dart';
import 'widgets/auth_switch_link.dart';
import '../components/custom_header_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool isDarkMode = false;
  final bool _passwordVisible = false;
  late AuthAnimationController _authAnimationController;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _authAnimationController = AuthAnimationController(vsync: this);
    _authAnimationController.startAnimations();
  }
Future<void> _login() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    if (mounted) {
      setState(() {
        _errorMessage = "Please fill in all fields.";
      });
    }
    return;
  }

  if (mounted) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  }

  try {
    User? user = await _authController.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      //  get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection("users")   
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc.data()?['role'];

        // Start exit animation
        await _authAnimationController.exitController.forward();

        // Navigate based on role
        //fix: use mounted to avoid memory leaks
        if (role == 'doctor') {
          if (mounted) Navigator.pushReplacementNamed(context, 'drhome');
        } else {
          if (mounted) Navigator.pushReplacementNamed(context, 'home');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "User data not found.";
          });
        }
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _toggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authAnimationController.dispose();
    super.dispose();
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

          // the auth form with animations
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
              title: "Welcome Back",
              subtitle:  "Sign in to continue your wellness journey",
              errorMessage: _errorMessage,
              fields: [
                CustomTextFormField(
                  controller: _emailController,
                  hintText: "Email Address",
                  prefixIcon: Icons.email_outlined,
                ),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_passwordVisible,
                ),
              ],
              actionButton: CustomButton(
                onPressed: _isLoading ? null : _login,
                text: "Sign In",
                isLoading: _isLoading,
              ),
              bottomWidget: [
                const SizedBox(height: 25),
                AuthLinkRow(
                  leadingText: "Don't have an account?",
                  actionText: "Sign Up",
                  onTap: () {
                    Navigator.pushNamed(context, 'signup');
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ],
        ),
      );
  }
}