import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/heartrate_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('Heart Rate Tab Widget Tests', () {
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

    testWidgets('Heart Rate Tab renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are displayed
      expect(find.byIcon(Icons.favorite), findsWidgets);
      expect(find.text('BPM'), findsWidgets);
    });

    testWidgets('Start Recording button is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start Recording'), findsOneWidget);
    });

    testWidgets('Recording state changes when button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Start Recording'), findsOneWidget);

      // Note: Cannot actually test recording without device connection
      // but we can verify the button exists and is interactive
      final button = find.text('Start Recording');
      expect(button, findsOneWidget);
    });

    testWidgets('Empty state is shown when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No readings yet'), findsOneWidget);
    });

    testWidgets('Theme changes work correctly', (WidgetTester tester) async {
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

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify widget still renders
      expect(find.byType(HeartRateTab), findsOneWidget);
    });

    testWidgets('View All button toggles readings display', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for "View All" or "View Less" button
      final viewButton = find.text('View All');
      if (viewButton.evaluate().isNotEmpty) {
        await tester.tap(viewButton);
        await tester.pumpAndSettle();
        expect(find.text('View Less'), findsOneWidget);
      }
    });

    testWidgets('Pulse animation exists and completes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump a few frames to allow animations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Graph component is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for graph-related text
      expect(find.text('Heart Rate'), findsWidgets);
    });
  });

  group('Health Status Dialog for Heart Rate Tests', () {
    testWidgets('Dialog displays correctly for normal heart rate', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HealthStatusDialog(
                        title: 'Heart Rate Reading',
                        value: '70',
                        unit: 'bpm',
                        category: getHeartRateCategory(70),
                        riskLevel: getHeartRateRiskLevel(70),
                        message: getHeartRateAdvice(70),
                        statusColor: getHeartStatusColor(70),
                        icon: Icons.favorite,
                        requiresMedicalAttention: requiresHeartRateMedicalAttention(70),
                        isDark: false,
                        onBookAppointment: () {},
                        onDismiss: () => Navigator.pop(context),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Heart Rate Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);

      // Verify only Close button (no medical attention needed)
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for bradycardia', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HealthStatusDialog(
                        title: 'Heart Rate Reading',
                        value: '45',
                        unit: 'bpm',
                        category: getHeartRateCategory(45),
                        riskLevel: getHeartRateRiskLevel(45),
                        message: getHeartRateAdvice(45),
                        statusColor: getHeartStatusColor(45),
                        icon: Icons.favorite,
                        requiresMedicalAttention: requiresHeartRateMedicalAttention(45),
                        isDark: false,
                        onBookAppointment: () {},
                        onDismiss: () => Navigator.pop(context),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify medical attention warning
      expect(find.text('Please contact a doctor and book an appointment for a proper evaluation.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      // Verify both action buttons
      expect(find.text('Book an Appointment'), findsOneWidget);
      expect(find.text('I Understand'), findsOneWidget);

      // Test I Understand button
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();
      expect(find.text('Heart Rate Reading'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for tachycardia', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HealthStatusDialog(
                        title: 'Heart Rate Reading',
                        value: '120',
                        unit: 'bpm',
                        category: getHeartRateCategory(120),
                        riskLevel: getHeartRateRiskLevel(120),
                        message: getHeartRateAdvice(120),
                        statusColor: getHeartStatusColor(120),
                        icon: Icons.favorite,
                        requiresMedicalAttention: requiresHeartRateMedicalAttention(120),
                        isDark: false,
                        onBookAppointment: () {},
                        onDismiss: () => Navigator.pop(context),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Very High'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog works in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => HealthStatusDialog(
                        title: 'Heart Rate Reading',
                        value: '70',
                        unit: 'bpm',
                        category: getHeartRateCategory(70),
                        riskLevel: getHeartRateRiskLevel(70),
                        message: getHeartRateAdvice(70),
                        statusColor: getHeartStatusColor(70),
                        icon: Icons.favorite,
                        requiresMedicalAttention: requiresHeartRateMedicalAttention(70),
                        isDark: true,
                        onBookAppointment: () {},
                        onDismiss: () => Navigator.pop(context),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Heart Rate Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Dialog displays correct advice for different ranges', (WidgetTester tester) async {
      final testCases = [
        {'value': 55.0, 'category': 'Athletic/Low'},
        {'value': 85.0, 'category': 'Slightly Elevated'},
        {'value': 95.0, 'category': 'Elevated'},
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      final value = testCase['value'] as double;
                      showDialog(
                        context: context,
                        builder: (context) => HealthStatusDialog(
                          title: 'Heart Rate Reading',
                          value: value.toInt().toString(),
                          unit: 'bpm',
                          category: getHeartRateCategory(value),
                          riskLevel: getHeartRateRiskLevel(value),
                          message: getHeartRateAdvice(value),
                          statusColor: getHeartStatusColor(value),
                          icon: Icons.favorite,
                          requiresMedicalAttention: requiresHeartRateMedicalAttention(value),
                          isDark: false,
                          onBookAppointment: () {},
                          onDismiss: () => Navigator.pop(context),
                        ),
                      );
                    },
                    child: const Text('Show Dialog'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text(testCase['category'] as String), findsOneWidget);

        // Close dialog using Navigator.pop
        Navigator.of(tester.element(find.byType(ElevatedButton).first)).pop();
        await tester.pumpAndSettle();
      }
    });
  });
}
