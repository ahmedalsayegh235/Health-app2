import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/spo2_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('SpO2 Integration Tests', () {
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
              body: SpO2Tab(isDark: false),
            ),
          ),
        ),
      );
    }

    testWidgets('Complete SpO2 monitoring flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Start Measuring'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
      expect(find.text('No SpO2 readings yet'), findsOneWidget);

      // Step 2: Verify SpO2 icon is displayed
      expect(find.byIcon(Icons.air), findsWidgets);

      // Step 3: Verify info card
      expect(find.text('Normal SpO2 levels are 95-100%. Values below 90% may require medical attention.'), findsOneWidget);
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
                  builder: (context, theme, _) => SpO2Tab(
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
      expect(find.text('Start Measuring'), findsOneWidget);

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify state is maintained
      expect(find.text('Start Measuring'), findsOneWidget);

      // Toggle back
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Start Measuring'), findsOneWidget);
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
      expect(find.byType(SpO2Tab), findsOneWidget);
    });
  });

  group('SpO2 Health Status Dialog Integration Tests', () {
    testWidgets('Dialog workflow for optimal SpO2', (WidgetTester tester) async {
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
                          title: 'SpO2 Reading',
                          value: '98',
                          unit: '%',
                          category: 'Optimal',
                          riskLevel: 'Low',
                          message: 'Your oxygen saturation is optimal.',
                          statusColor: Colors.green,
                          icon: Icons.air,
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
      expect(find.text('SpO2 Reading'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('SpO2 Reading'), findsNothing);
    });

    testWidgets('Dialog workflow for critical SpO2 with appointment booking', (WidgetTester tester) async {
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
                            title: 'SpO2 Reading',
                            value: '85',
                            unit: '%',
                            category: 'Severe Hypoxemia',
                            riskLevel: 'High',
                            message: 'Your oxygen saturation is severely low. This requires urgent medical intervention.',
                            statusColor: Colors.red,
                            icon: Icons.air,
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
      expect(find.text('SpO2 Reading'), findsNothing);
    });

    testWidgets('Dialog shows different severity levels correctly', (WidgetTester tester) async {
      final testCases = [
        {'value': '98', 'category': 'Optimal', 'needsAttention': false},
        {'value': '93', 'category': 'Mild Hypoxemia', 'needsAttention': true},
        {'value': '90', 'category': 'Moderate Hypoxemia', 'needsAttention': true},
        {'value': '85', 'category': 'Severe Hypoxemia', 'needsAttention': true},
      ];

      for (final testCase in testCases) {
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
                            title: 'SpO2 Reading',
                            value: testCase['value'] as String,
                            unit: '%',
                            category: testCase['category'] as String,
                            riskLevel: testCase['needsAttention'] as bool ? 'High' : 'Low',
                            message: 'Test message',
                            statusColor: testCase['needsAttention'] as bool ? Colors.red : Colors.green,
                            icon: Icons.air,
                            requiresMedicalAttention: testCase['needsAttention'] as bool,
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

        expect(find.text(testCase['category'] as String), findsOneWidget);
        expect(find.text(testCase['value'] as String), findsOneWidget);

        if (testCase['needsAttention'] as bool) {
          expect(find.text('Book an Appointment'), findsOneWidget);
          await tester.tap(find.text('I Understand'));
        } else {
          expect(find.text('Close'), findsOneWidget);
          await tester.tap(find.text('Close'));
        }

        await tester.pumpAndSettle();
        expect(find.text('SpO2 Reading'), findsNothing);
      }
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
                          title: 'SpO2 Reading',
                          value: '98',
                          unit: '%',
                          category: 'Optimal',
                          riskLevel: 'Low',
                          message: 'Your oxygen saturation is optimal.',
                          statusColor: Colors.green,
                          icon: Icons.air,
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

        expect(find.text('SpO2 Reading'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.text('SpO2 Reading'), findsNothing);
      }

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });
  });
}
