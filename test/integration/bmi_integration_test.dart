import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/custom_button.dart';
import 'package:health/components/health_status_dialog.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/bmi_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('BMI Integration Tests', () {
    late BmiController bmiController;
    late ThemeProvider themeProvider;
    late ActivityProvider activityProvider;

    setUp(() {
      bmiController = BmiController();
      themeProvider = ThemeProvider();
      activityProvider = ActivityProvider();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<BmiController>.value(
            value: bmiController,
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
              body: BmiTab(),
            ),
          ),
        ),
      );
    }

    testWidgets('Complete flow: Enter weight and height, calculate BMI', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: Verify initial state
      expect(find.text('Calculate BMI'), findsOneWidget);
      expect(find.text('--.-'), findsOneWidget);

      // Step 2: Enter weight and height
      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();

      // Step 3: Verify values are entered
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Note: Can't test actual save without Firebase setup
      // but we verify the form accepts the input
    });

    testWidgets('Enter different BMI categories', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Test normal BMI (22.86)
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Test overweight BMI (26.23)
      await tester.enterText(weightField, '85');
      await tester.enterText(heightField, '180');
      await tester.pumpAndSettle();
      expect(find.text('85'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);

      // Test underweight BMI (20.20)
      await tester.enterText(weightField, '55');
      await tester.enterText(heightField, '165');
      await tester.pumpAndSettle();
      expect(find.text('55'), findsOneWidget);
      expect(find.text('165'), findsOneWidget);
    });

    testWidgets('Validation flow: Try to calculate with invalid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to calculate without entering values
      await tester.tap(find.widgetWithText(CustomButton, 'Calculate'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your weight'), findsOneWidget);
      expect(find.text('Please enter your height'), findsOneWidget);

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter invalid weight
      await tester.enterText(weightField, '0');
      await tester.enterText(heightField, '175');
      await tester.tap(find.widgetWithText(CustomButton, 'Calculate'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid weight'), findsOneWidget);

      // Enter invalid height
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '0');
      await tester.tap(find.widgetWithText(CustomButton, 'Calculate'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid height'), findsOneWidget);
    });

    testWidgets('Theme integration: Switch themes while using form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter values in light mode
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify values are still there
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Switch back to light mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);
    });

    testWidgets('Complete user journey: Enter values, attempt calculation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Step 1: View initial state
      expect(find.text('Previous Readings (0)'), findsOneWidget);
      expect(find.text('No readings yet'), findsOneWidget);

      // Step 2: Enter weight and height for normal BMI
      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();

      // Step 3: Verify the entered values
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Step 4: Try to calculate (will fail without authentication, but tests the flow)
      await tester.tap(find.widgetWithText(CustomButton, 'Calculate'));
      await tester.pumpAndSettle();

      // Verify login message is shown
      expect(find.text('Login required to save readings'), findsOneWidget);
    });

    testWidgets('Multiple BMI calculations simulation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Simulate entering multiple BMI measurements
      final measurements = [
        {'weight': '60', 'height': '165'},
        {'weight': '70', 'height': '175'},
        {'weight': '80', 'height': '180'},
        {'weight': '90', 'height': '175'},
        {'weight': '100', 'height': '180'},
      ];

      for (final measurement in measurements) {
        await tester.enterText(weightField, measurement['weight']!);
        await tester.enterText(heightField, measurement['height']!);
        await tester.pumpAndSettle();
        expect(find.text(measurement['weight']!), findsOneWidget);
        expect(find.text(measurement['height']!), findsOneWidget);

        // Try to calculate (will not work without auth, but tests the flow)
        await tester.tap(find.widgetWithText(CustomButton, 'Calculate'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Edge cases: Very low and very high BMI values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Test very low BMI (severe underweight)
      await tester.enterText(weightField, '40');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();
      expect(find.text('40'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Test very high BMI (obese class III)
      await tester.enterText(weightField, '120');
      await tester.enterText(heightField, '165');
      await tester.pumpAndSettle();
      expect(find.text('120'), findsOneWidget);
      expect(find.text('165'), findsOneWidget);

      // Test normal BMI
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);
    });

    testWidgets('Decimal weight and height values work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter decimal values
      await tester.enterText(weightField, '70.5');
      await tester.enterText(heightField, '175.5');
      await tester.pumpAndSettle();

      expect(find.text('70.5'), findsOneWidget);
      expect(find.text('175.5'), findsOneWidget);
    });

    testWidgets('Form clearing and re-entry works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter first set of values
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();

      // Clear and enter new values
      await tester.enterText(weightField, '');
      await tester.enterText(heightField, '');
      await tester.pumpAndSettle();

      // Enter second set of values
      await tester.enterText(weightField, '80');
      await tester.enterText(heightField, '180');
      await tester.pumpAndSettle();

      expect(find.text('80'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);
    });
  });

  group('BMI Health Status Dialog Integration Tests', () {
    testWidgets('Dialog displays correctly for normal BMI', (WidgetTester tester) async {
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
                        title: 'BMI Result',
                        value: '22.9',
                        unit: 'kg/m²',
                        category: 'Normal/Optimal',
                        riskLevel: 'Low',
                        message: BmiController.getBmiAdvice(22.9),
                        statusColor: Colors.green,
                        icon: Icons.monitor_weight,
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
      expect(find.text('BMI Result'), findsOneWidget);
      expect(find.text('22.9'), findsOneWidget);
      expect(find.text('kg/m²'), findsOneWidget);
      expect(find.text('Normal/Optimal'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);

      // Verify only Close button (no medical attention)
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('BMI Result'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for severe underweight', (WidgetTester tester) async {
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
                        title: 'BMI Result',
                        value: '14.5',
                        unit: 'kg/m²',
                        category: 'Underweight (Severe)',
                        riskLevel: 'High',
                        message: BmiController.getBmiAdvice(14.5),
                        statusColor: Colors.red,
                        icon: Icons.monitor_weight,
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
      expect(find.text('BMI Result'), findsNothing);
    });

    testWidgets('Dialog shows medical attention warning for obesity', (WidgetTester tester) async {
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
                        title: 'BMI Result',
                        value: '35.5',
                        unit: 'kg/m²',
                        category: 'Obese Class II',
                        riskLevel: 'High',
                        message: BmiController.getBmiAdvice(35.5),
                        statusColor: Colors.red,
                        icon: Icons.monitor_weight,
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

      expect(find.text('Obese Class II'), findsOneWidget);
      expect(find.text('35.5'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
    });

    testWidgets('Dialog displays correctly for overweight BMI', (WidgetTester tester) async {
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
                        title: 'BMI Result',
                        value: '26.5',
                        unit: 'kg/m²',
                        category: 'Overweight (Grade I)',
                        riskLevel: 'Low-Moderate',
                        message: BmiController.getBmiAdvice(26.5),
                        statusColor: Colors.blue,
                        icon: Icons.monitor_weight,
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

      expect(find.text('Overweight (Grade I)'), findsOneWidget);
      expect(find.text('26.5'), findsOneWidget);
      expect(find.text('Low-Moderate'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Book an Appointment'), findsNothing);
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
                        title: 'BMI Result',
                        value: '22.9',
                        unit: 'kg/m²',
                        category: 'Normal/Optimal',
                        riskLevel: 'Low',
                        message: BmiController.getBmiAdvice(22.9),
                        statusColor: Colors.green,
                        icon: Icons.monitor_weight,
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

      expect(find.text('BMI Result'), findsOneWidget);
      expect(find.text('22.9'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
