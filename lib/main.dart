import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/blood_sugar_controller.dart';
import 'package:health/controllers/health_score_controller.dart';
import 'package:health/dr_views/dr_home.dart';
import 'package:health/firebase_options.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/controllers/user_provider.dart';
import 'patient_views/splash_screen_views.dart';
import 'package:health/patient_views/home.dart';
import 'package:health/auth_view/login.dart';
import 'package:health/auth_view/signup.dart';
import 'package:provider/provider.dart';
import 'helpers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()..loadActivities()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => BmiController()),
        ChangeNotifierProvider(create: (_) => BloodSugarController()),
        
        // FIXED: Use ProxyProvider to get the actual instances from the tree
        ChangeNotifierProxyProvider2<BmiController, SensorProvider, HealthScoreProvider>(
          create: (context) => HealthScoreProvider(
            bmiController: Provider.of<BmiController>(context, listen: false),
            sensorProvider: Provider.of<SensorProvider>(context, listen: false),
          ),
          update: (context, bmi, sensor, previous) => 
            previous ?? HealthScoreProvider(
              bmiController: bmi,
              sensorProvider: sensor,
            ),
        ),
      ],
      child: const MainApp(),
    ),
  );
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
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const AuthWrapper(),
          routes: {
            'signup': (context) => SignUpPage(),
            'login': (context) => const LoginPage(),
            'home': (context) => const HomePage(),
            'splash': (context) => const SplashScreenViews(),
            'drhome': (context) => const DrHomePage(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: SplashScreenViews());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'];

            if (role == 'doctor') {
              return const DrHomePage();
            } else {
              return const HomePage();
            }
          },
        );
      },
    );
  }
}