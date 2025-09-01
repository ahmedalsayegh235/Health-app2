import 'package:flutter/material.dart';
import 'package:health/controllers/auth_controller.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/models/user_model.dart';
import 'package:health/providers/user_provider.dart';
import 'package:health/patient_views/tabs/widgets/profile/header_background_profile.dart';
import 'package:health/patient_views/tabs/widgets/profile/password_dialog_profile.dart';
import 'package:health/patient_views/tabs/widgets/profile/profile_content.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isSaving = false;

  AnimationController? _fadeController;
  AnimationController? _scaleController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  String? _originalEmail;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    if (_isDisposed) return;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOutQuart));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _fadeController?.forward();
        _scaleController?.forward();
        _slideController?.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _originalEmail = user.email;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nameController.dispose();
    _emailController.dispose();
    _fadeController?.dispose();
    _scaleController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(UserModel user, [String? password]) async {
    if (!_formKey.currentState!.validate()) return;

    bool emailChanged = _emailController.text.trim() != _originalEmail;
    bool nameChanged = _nameController.text.trim() != user.name;

    // Require password if email changed
    if (emailChanged && (password == null || password.isEmpty)) {
      await showPasswordDialog(
        context: context,
        user: user,
        onConfirm: (user, enteredPassword) async {
          await _saveProfile(user, enteredPassword);
        },
      );
      return;
    }

    if (!emailChanged && !nameChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No changes to save")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authController = AuthController();

      final message = await authController.updateUser(
        userId: user.id!,
        name: nameChanged ? _nameController.text.trim() : null,
        email: emailChanged ? _emailController.text.trim() : null,
        password: password,
      );

      // Update local provider
      final updatedUser = UserModel(
        id: user.id,
        role: user.role,
        name: nameChanged ? _nameController.text.trim() : user.name,
        email: emailChanged ? _emailController.text.trim() : user.email,
        cpr: user.cpr,
        gender: user.gender,
      );

      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

      if (emailChanged) _originalEmail = _emailController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightgreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.headerGradient(isDark),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          HeaderBackground(),
          SafeArea(
            child: ProfileContent(
              user: user,
              isDark: isDark,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
              nameController: _nameController,
              emailController: _emailController,
              formKey: _formKey,
              isSaving: _isSaving,
              onSave: (user) async => await _saveProfile(user),
            ),
          ),
        ],
      ),
    );
  }
}
