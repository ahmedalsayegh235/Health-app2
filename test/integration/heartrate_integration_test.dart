import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/heartrate_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('Heart Rate Integration Tests', () {
    late SensorProvider sensorProvider;
    late ThemeProvider themeProvider;
    late ActivityProvider activityProvider;

    setUp(() {
      sensorProvider = SensorProvider();
      themeProvider = ThemeProvider();
      activityProvider = ActivityProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SensorProvider>.value(value: sensorProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<ActivityProvider>.value(
            value: activityProvider,
          ),
        ],
        child: MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: HeartRateTab(isDark: false),
            ),
          ),
        ),
      );
    }

    testWidgets('Complete heart rate monitoring flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Start Recording'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
      expect(find.text('No readings yet'), findsOneWidget);

      // Step 2: Verify recording button is visible
      expect(find.byIcon(Icons.favorite), findsWidgets);

      // Note: Cannot actually test recording without device connection
      // but we verify the UI is ready for user interaction
    });

    testWidgets('View all readings toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for toggle button
      final viewAllButton = find.text('View All');
      if (viewAllButton.evaluate().isNotEmpty) {
        // Tap to expand
        await tester.tap(viewAllButton);
        await tester.pumpAndSettle();

        // Verify it changed to "View Less"
        expect(find.text('View Less'), findsOneWidget);

        // Tap again to collapse
        await tester.tap(find.text('View Less'));
        await tester.pumpAndSettle();

        // Verify it changed back
        expect(find.text('View All'), findsOneWidget);
      }
    });

    testWidgets('Theme toggle maintains state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SensorProvider>.value(value: sensorProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<ActivityProvider>.value(
              value: activityProvider,
            ),
          ],
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: Consumer<ThemeProvider>(
                  builder: (context, theme, _) => HeartRateTab(
                    isDark: theme.isDarkMode,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Start Recording'), findsOneWidget);

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify state is maintained
      expect(find.text('Start Recording'), findsOneWidget);

      // Toggle back
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Start Recording'), findsOneWidget);
    });

    testWidgets('Animation cycles complete without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump multiple animation frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('UI remains responsive during rapid interactions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapidly interact with various elements
      for (int i = 0; i < 5; i++) {
        // Try to tap view all button if it exists
        final viewAllButton = find.text('View All');
        if (viewAllButton.evaluate().isNotEmpty) {
          await tester.tap(viewAllButton);
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Toggle theme
        themeProvider.toggleTheme();
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Verify no crashes occurred
      expect(tester.takeException(), isNull);
      expect(find.byType(HeartRateTab), findsOneWidget);
    });
  });

  group('Heart Rate Health Status Dialog Integration Tests', () {
    testWidgets('Dialog workflow for normal heart rate', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => HealthStatusDialog(
                          title: 'Heart Rate Reading',
                          value: '70',
                          unit: 'bpm',
                          category: 'Optimal',
                          riskLevel: 'Low',
                          message: 'Your heart rate is optimal.',
                          statusColor: Colors.green,
                          icon: Icons.favorite,
                          requiresMedicalAttention: false,
                          isDark: false,
                          onBookAppointment: () {},
                          onDismiss: () => Navigator.pop(ctx),
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.text('Heart Rate Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Heart Rate Reading'), findsNothing);
    });

    testWidgets('Dialog workflow for critical heart rate with appointment booking', (WidgetTester tester) async {
      bool appointmentBooked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => HealthStatusDialog(
                            title: 'Heart Rate Reading',
                            value: '120',
                            unit: 'bpm',
                            category: 'Very High',
                            riskLevel: 'High',
                            message: 'Your heart rate is very high. Please contact a healthcare provider.',
                            statusColor: Colors.red,
                            icon: Icons.favorite,
                            requiresMedicalAttention: true,
                            isDark: false,
                            onBookAppointment: () {
                              appointmentBooked = true;
                              Navigator.pop(ctx);
                            },
                            onDismiss: () => Navigator.pop(ctx),
                          ),
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify medical attention warning
      expect(find.text('Please contact a doctor and book an appointment for a proper evaluation.'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
      expect(find.text('I Understand'), findsOneWidget);

      // Book appointment
      await tester.tap(find.text('Book an Appointment'));
      await tester.pumpAndSettle();

      // Verify appointment was booked
      expect(appointmentBooked, true);
      expect(find.text('Heart Rate Reading'), findsNothing);
    });

    testWidgets('Multiple dialog openings work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => HealthStatusDialog(
                          title: 'Heart Rate Reading',
                          value: '70',
                          unit: 'bpm',
                          category: 'Optimal',
                          riskLevel: 'Low',
                          message: 'Your heart rate is optimal.',
                          statusColor: Colors.green,
                          icon: Icons.favorite,
                          requiresMedicalAttention: false,
                          isDark: false,
                          onBookAppointment: () {},
                          onDismiss: () => Navigator.pop(ctx),
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Show and close dialog multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Heart Rate Reading'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.text('Heart Rate Reading'), findsNothing);
      }

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog respects barrierDismissible=false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => HealthStatusDialog(
                          title: 'Heart Rate Reading',
                          value: '120',
                          unit: 'bpm',
                          category: 'Very High',
                          riskLevel: 'High',
                          message: 'Your heart rate is very high.',
                          statusColor: Colors.red,
                          icon: Icons.favorite,
                          requiresMedicalAttention: true,
                          isDark: false,
                          onBookAppointment: () {},
                          onDismiss: () => Navigator.pop(ctx),
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to tap outside dialog (on barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog should still be visible
      expect(find.text('Heart Rate Reading'), findsOneWidget);

      // Close properly
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();

      expect(find.text('Heart Rate Reading'), findsNothing);
    });
  });
}
