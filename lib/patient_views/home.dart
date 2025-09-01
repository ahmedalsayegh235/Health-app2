import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health/controllers/auth_controller.dart';
import 'package:health/models/user_model.dart';
import 'package:health/controllers/user_provider.dart';
import 'package:health/patient_views/splash_screen_views.dart';
import 'package:health/patient_views/tabs/activity_tab.dart';
import 'package:health/patient_views/tabs/appointment_tab.dart';
import 'package:health/patient_views/tabs/chat_tab.dart';
import 'package:health/patient_views/tabs/home_tab.dart';
import 'package:health/patient_views/tabs/profile_tab.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_theme.dart';
import '../../helpers/theme_provider.dart';
import '../../controllers/animation/home_animation_controller.dart';
import '../../components/custom_drawer.dart';
import 'widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentNavIndex = 2;
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
      case 'Health Records':
        setState(() => _currentNavIndex = 1);
        break;
      case 'Appointments':
        setState(() => _currentNavIndex = 0);
        break;
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
        return AppointmentTab(scaffoldKey: _scaffoldKey,);
      case 1:
        return ActivityTab(scaffoldKey: _scaffoldKey);
      case 2:
        return  HomeTab(vsync: this, animations: _animations);
      case 3:
        return ChatTab();
      case 4:
        return ProfileTab();
      default:
        return HomeTab(vsync: this, animations: _animations);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Theme(
      data: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: _isLoading
          ? SplashScreenViews()
          : Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppTheme.backgroundColor(isDarkMode),

              // Shared drawer for all tabs
              drawer: CustomDrawer(
                isDarkMode: isDarkMode,
                onItemTap: _onDrawerItemTap,
              ),

              // Lazy-loaded tab content
              body: _getCurrentTab(),

              // Bottom navigation
              bottomNavigationBar: BottomNav(
                isDarkMode: isDarkMode,
                currentIndex: _currentNavIndex,
                onTap: (index) => setState(() => _currentNavIndex = index),
                navAnimationController: _animations.navAnimationController,
              ),
            ),
    );
  }
}
