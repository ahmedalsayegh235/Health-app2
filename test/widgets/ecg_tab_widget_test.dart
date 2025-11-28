import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/helpers/tab_helper.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/widgets/activity/ecg_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('ECG Tab Widget Tests', () {
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

    testWidgets('ECG Tab renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are displayed
      expect(find.byIcon(Icons.monitor_heart_outlined), findsWidgets);
    });

    testWidgets('Device mode indicator is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('ECG mode'), findsWidgets);
    });

    testWidgets('Recording button is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Start 30s Recording'), findsOneWidget);
    });

    testWidgets('Medical disclaimer is shown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Medical Disclaimer'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('Previous Readings section exists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Previous Readings'), findsOneWidget);
    });

    testWidgets('Empty state is shown when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No previous ECG recordings'), findsOneWidget);
    });

    testWidgets('Theme changes work correctly', (WidgetTester tester) async {
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

      // Toggle theme
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify widget still renders
      expect(find.byType(ECGTab), findsOneWidget);
    });

    testWidgets('Animations complete without errors', (WidgetTester tester) async {
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

  group('Health Status Dialog for ECG Tests', () {
    testWidgets('Dialog displays correctly for optimal ECG heart rate', (WidgetTester tester) async {
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
                        title: 'ECG Reading',
                        value: '70',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(70)} | Normal Sinus Rhythm',
                        riskLevel: getECGHeartRateRiskLevel(70),
                        message: '${getECGHeartRateAdvice(70)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Normal Sinus Rhythm')}',
                        statusColor: getECGHeartRateStatusColor(70),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(70),
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
      expect(find.text('ECG Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.textContaining('Optimal'), findsOneWidget);
      expect(find.textContaining('Normal Sinus Rhythm'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);

      // Verify only Close button (no medical attention needed)
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for ECG bradycardia', (WidgetTester tester) async {
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
                        title: 'ECG Reading',
                        value: '45',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(45)} | Bradycardia',
                        riskLevel: getECGHeartRateRiskLevel(45),
                        message: '${getECGHeartRateAdvice(45)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Bradycardia')}',
                        statusColor: getECGHeartRateStatusColor(45),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(45) ||
                            requiresECGRhythmMedicalAttention('Bradycardia'),
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

    testWidgets('Dialog shows medical attention warning for irregular rhythm', (WidgetTester tester) async {
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
                        title: 'ECG Reading',
                        value: '75',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(75)} | Irregular Rhythm',
                        riskLevel: getECGHeartRateRiskLevel(75),
                        message: '${getECGHeartRateAdvice(75)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Irregular Rhythm')}',
                        statusColor: getECGHeartRateStatusColor(75),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(75) ||
                            requiresECGRhythmMedicalAttention('Irregular Rhythm'),
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

      expect(find.textContaining('Irregular Rhythm'), findsWidgets);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog shows warning for tachycardia', (WidgetTester tester) async {
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
                        title: 'ECG Reading',
                        value: '120',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(120)} | Tachycardia',
                        riskLevel: getECGHeartRateRiskLevel(120),
                        message: '${getECGHeartRateAdvice(120)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Tachycardia')}',
                        statusColor: getECGHeartRateStatusColor(120),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(120) ||
                            requiresECGRhythmMedicalAttention('Tachycardia'),
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
      expect(find.textContaining('Tachycardia'), findsWidgets);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog handles athletic heart rate with normal rhythm', (WidgetTester tester) async {
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
                        title: 'ECG Reading',
                        value: '55',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(55)} | Normal Sinus Rhythm',
                        riskLevel: getECGHeartRateRiskLevel(55),
                        message: '${getECGHeartRateAdvice(55)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Normal Sinus Rhythm')}',
                        statusColor: getECGHeartRateStatusColor(55),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(55) ||
                            requiresECGRhythmMedicalAttention('Normal Sinus Rhythm'),
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

      expect(find.text('Athletic/Low'), findsOneWidget);
      expect(find.textContaining('athletic'), findsWidgets);
      expect(find.text('Close'), findsOneWidget);
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
                        title: 'ECG Reading',
                        value: '70',
                        unit: 'bpm',
                        category: '${getECGHeartRateCategory(70)} | Normal Sinus Rhythm',
                        riskLevel: getECGHeartRateRiskLevel(70),
                        message: '${getECGHeartRateAdvice(70)}\n\nRhythm Analysis: ${getECGRhythmAdvice('Normal Sinus Rhythm')}',
                        statusColor: getECGHeartRateStatusColor(70),
                        icon: Icons.monitor_heart,
                        requiresMedicalAttention: requiresECGMedicalAttention(70),
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

      expect(find.text('ECG Reading'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
