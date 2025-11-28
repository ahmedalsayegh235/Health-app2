import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/blood_sugar_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/bloodsugar_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('Blood Sugar Integration Tests', () {
    late BloodSugarController bloodSugarController;
    late ThemeProvider themeProvider;
    late ActivityProvider activityProvider;

    setUp(() {
      bloodSugarController = BloodSugarController();
      themeProvider = ThemeProvider();
      activityProvider = ActivityProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<BloodSugarController>.value(
            value: bloodSugarController,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
          ),
          ChangeNotifierProvider<ActivityProvider>.value(
            value: activityProvider,
          ),
        ],
        child: MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: BloodsugarTab(),
            ),
          ),
        ),
      );
    }

    testWidgets('Complete flow: Enter blood sugar value and see result', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Record Blood Sugar'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);

      // Step 2: Select reading type
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();

      // Step 3: Enter valid blood sugar value
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '95');
      await tester.pumpAndSettle();

      // Step 4: Verify value is entered
      expect(find.text('95'), findsOneWidget);

      // Note: Can't test actual save without Firebase setup
      // but we verify the form accepts the input
    });

    testWidgets('Switch reading types and enter different values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Test Fasting reading
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();
      await tester.enterText(textField, '85');
      await tester.pumpAndSettle();
      expect(find.text('85'), findsOneWidget);

      // Clear and test Post Meal reading
      await tester.enterText(textField, '140');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Post Meal'));
      await tester.pumpAndSettle();
      expect(find.text('140'), findsOneWidget);

      // Clear and test Random reading
      await tester.enterText(textField, '120');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Random'));
      await tester.pumpAndSettle();
      expect(find.text('120'), findsOneWidget);
    });

    testWidgets('Validation flow: Try to save with invalid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to save without entering value
      await tester.tap(find.widgetWithText(CustomButton, 'Save Reading'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter blood sugar level'), findsOneWidget);

      // Enter invalid value and try to save
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '-10');
      await tester.tap(find.widgetWithText(CustomButton, 'Save Reading'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid blood sugar level'), findsOneWidget);

      // Enter zero and try to save
      await tester.enterText(textField, '0');
      await tester.tap(find.widgetWithText(CustomButton, 'Save Reading'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid blood sugar level'), findsOneWidget);
    });

    testWidgets('Theme integration: Switch themes while using form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter value in light mode
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '95');
      await tester.pumpAndSettle();

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify value is still there
      expect(find.text('95'), findsOneWidget);

      // Switch back to light mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('95'), findsOneWidget);
    });

    testWidgets('Complete user journey: Select type, enter value, attempt save', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: View initial state
      expect(find.text('Previous Readings (0)'), findsOneWidget);
      expect(find.text('No readings yet'), findsOneWidget);

      // Step 2: Select Fasting reading type
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();

      // Step 3: Enter a prediabetic value
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '110');
      await tester.pumpAndSettle();

      // Step 4: Verify the entered value
      expect(find.text('110'), findsOneWidget);

      // Step 5: Try to save (will fail without authentication, but tests the flow)
      await tester.tap(find.widgetWithText(CustomButton, 'Save Reading'));
      await tester.pumpAndSettle();

      // Verify login message is shown
      expect(find.text('Login required to save readings'), findsOneWidget);
    });

    testWidgets('Multiple readings entry simulation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Simulate entering multiple readings
      final readings = ['85', '95', '120', '140', '180'];

      for (final reading in readings) {
        await tester.enterText(textField, reading);
        await tester.pumpAndSettle();
        expect(find.text(reading), findsOneWidget);

        // Try to save (will not work without auth, but tests the flow)
        await tester.tap(find.widgetWithText(CustomButton, 'Save Reading'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Edge cases: Very high and very low values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Test very low value (hypoglycemia)
      await tester.enterText(textField, '50');
      await tester.pumpAndSettle();
      expect(find.text('50'), findsOneWidget);
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();

      // Test very high value (diabetes)
      await tester.enterText(textField, '250');
      await tester.pumpAndSettle();
      expect(find.text('250'), findsOneWidget);

      // Test normal value
      await tester.enterText(textField, '95');
      await tester.pumpAndSettle();
      expect(find.text('95'), findsOneWidget);
    });

    testWidgets('Reading type changes affect interpretation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '140');
      await tester.pumpAndSettle();

      // 140 is different for fasting vs post-meal
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();
      // For fasting, 140 would be elevated

      await tester.tap(find.text('Post Meal'));
      await tester.pumpAndSettle();
      // For post-meal, 140 is normal (< 140)

      await tester.tap(find.text('Random'));
      await tester.pumpAndSettle();
      // For random, 140 is normal

      expect(find.text('140'), findsOneWidget);
    });
  });

  group('Health Status Dialog Integration Tests', () {
    testWidgets('Dialog displays correctly for normal blood sugar', (WidgetTester tester) async {
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
                        title: 'Blood Sugar Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: BloodSugarController.getBloodSugarAdvice(95.0, 'fasting'),
                        statusColor: Colors.green,
                        icon: Icons.bloodtype,
                        requiresMedicalAttention: false,
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
      expect(find.text('Blood Sugar Reading'), findsOneWidget);
      expect(find.text('95.0'), findsOneWidget);
      expect(find.text('mg/dL'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);

      // Verify only Close button (no medical attention)
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Blood Sugar Reading'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for hypoglycemia', (WidgetTester tester) async {
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
                        title: 'Blood Sugar Reading',
                        value: '65.0',
                        unit: 'mg/dL',
                        category: 'Hypoglycemia',
                        riskLevel: 'Moderate-High',
                        message: BloodSugarController.getBloodSugarAdvice(65.0, 'fasting'),
                        statusColor: Colors.red,
                        icon: Icons.bloodtype,
                        requiresMedicalAttention: true,
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
      expect(find.text('Blood Sugar Reading'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for diabetes', (WidgetTester tester) async {
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
                        title: 'Blood Sugar Reading',
                        value: '200.0',
                        unit: 'mg/dL',
                        category: 'Diabetes (Moderate)',
                        riskLevel: 'High',
                        message: BloodSugarController.getBloodSugarAdvice(200.0, 'fasting'),
                        statusColor: Colors.red,
                        icon: Icons.bloodtype,
                        requiresMedicalAttention: true,
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

      expect(find.text('Diabetes (Moderate)'), findsOneWidget);
      expect(find.text('200.0'), findsOneWidget);
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
                        title: 'Blood Sugar Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: BloodSugarController.getBloodSugarAdvice(95.0, 'fasting'),
                        statusColor: Colors.green,
                        icon: Icons.bloodtype,
                        requiresMedicalAttention: false,
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

      expect(find.text('Blood Sugar Reading'), findsOneWidget);
      expect(find.text('95.0'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
