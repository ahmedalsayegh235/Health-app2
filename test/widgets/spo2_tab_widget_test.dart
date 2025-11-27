import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/spo2_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('SpO2 Tab Widget Tests', () {
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

    testWidgets('SpO2 Tab renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are displayed
      expect(find.byIcon(Icons.air), findsWidgets);
      expect(find.text('SpO2'), findsWidgets);
    });

    testWidgets('Start Measuring button is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start Measuring'), findsOneWidget);
    });

    testWidgets('Empty state is shown when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No SpO2 readings yet'), findsOneWidget);
    });

    testWidgets('Info card is displayed with health info', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Normal SpO2 levels are 95-100%. Values below 90% may require medical attention.'), findsOneWidget);
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

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify widget still renders
      expect(find.byType(SpO2Tab), findsOneWidget);
    });

    testWidgets('Pulse animation exists and completes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump a few frames
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify no exceptions occurred
      expect(tester.takeException(), isNull);
    });
  });

  group('Health Status Dialog for SpO2 Tests', () {
    testWidgets('Dialog displays correctly for optimal SpO2', (WidgetTester tester) async {
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
                        title: 'SpO2 Reading',
                        value: '98',
                        unit: '%',
                        category: getSPo2Category(98),
                        riskLevel: getSPo2RiskLevel(98),
                        message: getSPo2Advice(98),
                        statusColor: getSPo2StatusColor(98),
                        icon: Icons.air,
                        requiresMedicalAttention: requiresSPo2MedicalAttention(98),
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
      expect(find.text('SpO2 Reading'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('Optimal'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);

      // Verify only Close button (no medical attention needed)
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for hypoxemia', (WidgetTester tester) async {
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
                        title: 'SpO2 Reading',
                        value: '90',
                        unit: '%',
                        category: getSPo2Category(90),
                        riskLevel: getSPo2RiskLevel(90),
                        message: getSPo2Advice(90),
                        statusColor: getSPo2StatusColor(90),
                        icon: Icons.air,
                        requiresMedicalAttention: requiresSPo2MedicalAttention(90),
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
    });

    testWidgets('Dialog shows critical warning for severe hypoxemia', (WidgetTester tester) async {
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
                        title: 'SpO2 Reading',
                        value: '85',
                        unit: '%',
                        category: getSPo2Category(85),
                        riskLevel: getSPo2RiskLevel(85),
                        message: getSPo2Advice(85),
                        statusColor: getSPo2StatusColor(85),
                        icon: Icons.air,
                        requiresMedicalAttention: requiresSPo2MedicalAttention(85),
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

      expect(find.text('Severe Hypoxemia'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog handles all SpO2 ranges correctly', (WidgetTester tester) async {
      final testCases = [
        {'value': 95.0, 'category': 'Low Normal'},
        {'value': 96.0, 'category': 'Normal'},
        {'value': 99.0, 'category': 'Optimal'},
        {'value': 93.0, 'category': 'Mild Hypoxemia'},
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
                          title: 'SpO2 Reading',
                          value: value.toInt().toString(),
                          unit: '%',
                          category: getSPo2Category(value),
                          riskLevel: getSPo2RiskLevel(value),
                          message: getSPo2Advice(value),
                          statusColor: getSPo2StatusColor(value),
                          icon: Icons.air,
                          requiresMedicalAttention: requiresSPo2MedicalAttention(value),
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

        // Close the dialog
        final closeButton = find.text('Close').first;
        final understandButton = find.text('I Understand').first;
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
        } else {
          await tester.tap(understandButton);
        }
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Dialog shows artifact warning for 100% reading', (WidgetTester tester) async {
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
                        title: 'SpO2 Reading',
                        value: '100',
                        unit: '%',
                        category: getSPo2Category(100),
                        riskLevel: getSPo2RiskLevel(100),
                        message: getSPo2Advice(100),
                        statusColor: getSPo2StatusColor(100),
                        icon: Icons.air,
                        requiresMedicalAttention: requiresSPo2MedicalAttention(100),
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

      expect(find.text('Possibly Artifact'), findsOneWidget);
      expect(find.textContaining('artifact'), findsWidgets);
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
                        title: 'SpO2 Reading',
                        value: '98',
                        unit: '%',
                        category: getSPo2Category(98),
                        riskLevel: getSPo2RiskLevel(98),
                        message: getSPo2Advice(98),
                        statusColor: getSPo2StatusColor(98),
                        icon: Icons.air,
                        requiresMedicalAttention: requiresSPo2MedicalAttention(98),
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

      expect(find.text('SpO2 Reading'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
