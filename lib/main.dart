import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health/firebase_options.dart';
import 'views/splash_screen_views.dart';
import 'package:health/views/home_view/home.dart';
import 'package:health/views/auth_view/login.dart';
import 'package:health/views/auth_view/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'login',
      routes: {
        'signup': (context) => SignUpPage(),
        'login': (context) => const LoginPage(),
        'home': (context) => const HomePage(),
        'splash': (context) => const SplashScreenViews(),
      },
    );
  }
} 
