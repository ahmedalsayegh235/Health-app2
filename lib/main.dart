import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/dr_views/dr_appointment_tab.dart';
import 'package:health/dr_views/dr_chat_tab.dart';
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
        ChangeNotifierProvider(create: (_) => UserProvider(),),
        ChangeNotifierProvider(create: (_) => ActivityProvider()..loadActivities()), //for the stupid user
        ChangeNotifierProvider(create: (_) => SensorProvider()),
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
      // Listen to authentication state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while checking authentication state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not logged in → go to LoginPage
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // If user is logged in → fetch user data from Firestore
        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(
                'users',
              ) // Make sure this matches your collection name
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              // Show a loading spinner while fetching user data
              return const Scaffold(body: SplashScreenViews());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Handle case where user document is missing
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            // Get role from user document
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'];

            // Navigate to different home screens based on role
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
