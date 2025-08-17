import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health/firebase_options.dart';
import 'views/splash_screen_views.dart';
import 'package:health/views/home.dart';
import 'package:health/views/auth_view/login.dart';
import 'package:health/views/auth_view/signup.dart';
import 'package:provider/provider.dart';
import 'helpers/theme_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: 'login',
          routes: {
            'signup': (context) => SignUpPage(),
            'login': (context) => const LoginPage(),
            'home': (context) => const HomePage(),
            'splash': (context) => const SplashScreenViews(),
          },
        );
      },
    );
  }
}

