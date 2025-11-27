import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/ecg_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('ECG Integration Tests', () {
    late SensorProvider sensorProvider;
    late ThemeProvider themeProvider;

    setUp(() {
      sensorProvider = SensorProvider();
      themeProvider = ThemeProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SensorProvider>.value(value: sensorProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: ECGTab(isDark: false),
            ),
          ),
        ),
      );
    }

    testWidgets('Complete ECG monitoring flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Start 30s Recording'), findsOneWidget);
      expect(find.text('Previous Readings'), findsOneWidget);
      expect(find.text('No previous ECG recordings'), findsOneWidget);

      // Step 2: Verify ECG mode indicator
      expect(find.textContaining('ECG mode'), findsWidgets);

      // Step 3: Verify medical disclaimer
      expect(find.textContaining('Medical Disclaimer'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('Theme toggle maintains state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SensorProvider>.value(value: sensorProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ],
          child: MaterialApp(
            home: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: Consumer<ThemeProvider>(
                  builder: (context, theme, _) => ECGTab(
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
      expect(find.text('Start 30s Recording'), findsOneWidget);

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify state is maintained
      expect(find.text('Start 30s Recording'), findsOneWidget);

      // Toggle back
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Start 30s Recording'), findsOneWidget);
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
        // Toggle theme
        themeProvider.toggleTheme();
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();

      // Verify no crashes occurred
      expect(tester.takeException(), isNull);
      expect(find.byType(ECGTab), findsOneWidget);
    });
  });

  group('ECG Health Status Dialog Integration Tests', () {
    testWidgets('Dialog workflow for normal ECG with normal sinus rhythm', (WidgetTester tester) async {
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
                          title: 'ECG Reading',
                          value: '70',
                          unit: 'bpm',
                          category: 'Optimal | Normal Sinus Rhythm',
                          riskLevel: 'Low',
                          message: 'Your ECG-derived heart rate is optimal. The ECG shows good cardiac rhythm.',
                          statusColor: Colors.green,
                          icon: Icons.monitor_heart,
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
      expect(find.text('ECG Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.textContaining('Optimal'), findsOneWidget);
      expect(find.textContaining('Normal Sinus Rhythm'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('ECG Reading'), findsNothing);
    });

    testWidgets('Dialog workflow for bradycardia with appointment booking', (WidgetTester tester) async {
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
                            title: 'ECG Reading',
                            value: '45',
                            unit: 'bpm',
                            category: 'Very Low | Bradycardia',
                            riskLevel: 'Moderate',
                            message: 'Your ECG-derived heart rate is very low. Consult with a healthcare provider for ECG interpretation.',
                            statusColor: Colors.orange,
                            icon: Icons.monitor_heart,
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
      expect(find.text('ECG Reading'), findsNothing);
    });

    testWidgets('Dialog workflow for tachycardia', (WidgetTester tester) async {
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
                            title: 'ECG Reading',
                            value: '120',
                            unit: 'bpm',
                            category: 'Very High | Tachycardia',
                            riskLevel: 'High',
                            message: 'Your ECG-derived heart rate is very high. This requires medical evaluation.',
                            statusColor: Colors.red,
                            icon: Icons.monitor_heart,
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
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Very High'), findsOneWidget);
      expect(find.textContaining('Tachycardia'), findsWidgets);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog workflow for irregular rhythm', (WidgetTester tester) async {
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
                            title: 'ECG Reading',
                            value: '75',
                            unit: 'bpm',
                            category: 'Optimal | Irregular Rhythm',
                            riskLevel: 'Low',
                            message: 'Your heart rhythm appears irregular. This may indicate arrhythmia and requires medical evaluation.',
                            statusColor: Colors.green,
                            icon: Icons.monitor_heart,
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
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Irregular Rhythm'), findsWidgets);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog shows different ECG scenarios correctly', (WidgetTester tester) async {
      final testCases = [
        {'value': '55', 'rhythm': 'Normal Sinus Rhythm', 'needsAttention': false},
        {'value': '70', 'rhythm': 'Normal Sinus Rhythm', 'needsAttention': false},
        {'value': '120', 'rhythm': 'Tachycardia', 'needsAttention': true},
        {'value': '75', 'rhythm': 'Irregular Rhythm', 'needsAttention': true},
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
                            title: 'ECG Reading',
                            value: testCase['value'] as String,
                            unit: 'bpm',
                            category: 'Test | ${testCase['rhythm']}',
                            riskLevel: testCase['needsAttention'] as bool ? 'High' : 'Low',
                            message: 'Test message',
                            statusColor: testCase['needsAttention'] as bool ? Colors.red : Colors.green,
                            icon: Icons.monitor_heart,
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

        expect(find.textContaining(testCase['rhythm'] as String), findsWidgets);
        expect(find.text(testCase['value'] as String), findsOneWidget);

        if (testCase['needsAttention'] as bool) {
          expect(find.text('Book an Appointment'), findsOneWidget);
          await tester.tap(find.text('I Understand'));
        } else {
          expect(find.text('Close'), findsOneWidget);
          await tester.tap(find.text('Close'));
        }

        await tester.pumpAndSettle();
        expect(find.text('ECG Reading'), findsNothing);
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
                          title: 'ECG Reading',
                          value: '70',
                          unit: 'bpm',
                          category: 'Optimal | Normal Sinus Rhythm',
                          riskLevel: 'Low',
                          message: 'Your ECG is optimal.',
                          statusColor: Colors.green,
                          icon: Icons.monitor_heart,
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

        expect(find.text('ECG Reading'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.text('ECG Reading'), findsNothing);
      }

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });
  });
}
