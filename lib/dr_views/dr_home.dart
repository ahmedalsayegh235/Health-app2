import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/controllers/auth_controller.dart';
import 'package:health/dr_views/dr_appointment_tab.dart';
import 'package:health/dr_views/dr_chat_tab.dart';
import 'package:health/dr_views/dr_components/DrBottomNav.dart';
import 'package:health/dr_views/dr_components/dr_custom_drawer.dart';
import 'package:health/dr_views/dr_home_tab.dart';
import 'package:health/models/user_model.dart';
import 'package:health/providers/user_provider.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_theme.dart';
import '../../helpers/theme_provider.dart';
import '../../controllers/animation/home_animation_controller.dart';

class DrHomePage extends StatefulWidget {
  const DrHomePage({Key? key}) : super(key: key);

  @override
  State<DrHomePage> createState() => _DrHomePageState();
}

class _DrHomePageState extends State<DrHomePage> with TickerProviderStateMixin {
  int _currentNavIndex = 1;
  late HomeAnimations _animations;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animations = HomeAnimations(this);
    _animations.start();
    getUserData();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  // using provider to allow reactivity eliminates static code instead of calling user each tome
  void getUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final fetchedUser = await UserModel.getUserData(user.uid);
      if (fetchedUser != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(fetchedUser);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logoutUser() async {
    AuthController authController = AuthController();
    try {
      await authController.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handles drawer item taps
  void _onDrawerItemTap(String title) {
    // Close the drawer if open
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.pop(context);
    }

    switch (title) {
      case 'Logout':
        _logoutUser();
        break;
      default:
        break;
    }
  }

  // Lazy-load tabs
  // This helps in improving performance because it was a pain to deal with
  Widget _getCurrentTab() {
    switch (_currentNavIndex) {
      case 0:
        return DrAppointmentTab();
      case 1:
        return DrHomeTab(vsync: this, animations: _animations);
      case 2:
        return DrChatTab();
      default:
        return DrHomeTab(vsync: this, animations: _animations);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = Provider.of<UserProvider>(context).user;
    return Theme(
      data: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: _isLoading
          ? SplashScreenViews()
          : Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppTheme.backgroundColor(isDarkMode),
              appBar: AppBar(
                title: Text('Hi Dr. ${user!.name}'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      // Handle notifications
                    },
                  ),
                ],
              ),
              // Shared drawer for all tabs
              drawer: DrCustomDrawer(
                isDarkMode: isDarkMode,
                onItemTap: _onDrawerItemTap,
              ),

              // Lazy-loaded tab content
              body: _getCurrentTab(),

              // Bottom navigation
              bottomNavigationBar: DrBottomNav(
                isDarkMode: isDarkMode,
                currentIndex: _currentNavIndex,
                onTap: (index) => setState(() => _currentNavIndex = index),
                navAnimationController: _animations.navAnimationController,
              ),
            ),
    );
  }
}
