import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';

void main() {
  group('HealthStatusDialog Widget Tests', () {
    testWidgets('displays all required information correctly', (WidgetTester tester) async {
      bool appointmentPressed = false;
      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '25.5',
              unit: 'kg/m²',
              category: 'Overweight (Grade I)',
              riskLevel: 'Low-Moderate',
              message: 'You are slightly overweight (Grade I).',
              statusColor: Colors.blue,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: false,
              isDark: false,
              onBookAppointment: () {
                appointmentPressed = true;
              },
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('BMI Reading'), findsOneWidget);

      // Verify value and unit
      expect(find.text('25.5'), findsOneWidget);
      expect(find.text('kg/m²'), findsOneWidget);

      // Verify category
      expect(find.text('Overweight (Grade I)'), findsOneWidget);

      // Verify risk level is displayed
      expect(find.textContaining('Risk Level:'), findsOneWidget);
      expect(find.text('Low-Moderate'), findsOneWidget);

      // Verify message
      expect(find.text('You are slightly overweight (Grade I).'), findsOneWidget);

      // Verify icon
      expect(find.byIcon(Icons.monitor_weight), findsOneWidget);

      // Verify close button is shown (not requiring medical attention)
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('shows medical attention warning when required', (WidgetTester tester) async {
      bool appointmentPressed = false;
      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '32.0',
              unit: 'kg/m²',
              category: 'Obese Class I',
              riskLevel: 'Moderate-High',
              message: 'Your BMI indicates Class I Obesity.',
              statusColor: Colors.deepOrange,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: true,
              isDark: false,
              onBookAppointment: () {
                appointmentPressed = true;
              },
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      // Verify warning message is shown
      expect(
        find.text('Please contact a doctor and book an appointment for a proper evaluation.'),
        findsOneWidget,
      );

      // Verify warning icon
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      // Verify both buttons are shown
      expect(find.text('Book an Appointment'), findsOneWidget);
      expect(find.text('I Understand'), findsOneWidget);

      // Close button should NOT be shown
      expect(find.text('Close'), findsNothing);
    });

    testWidgets('book appointment button triggers callback', (WidgetTester tester) async {
      bool appointmentPressed = false;
      bool dismissPressed = false;

      // Set larger screen size for this test
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '32.0',
              unit: 'kg/m²',
              category: 'Obese Class I',
              riskLevel: 'Moderate-High',
              message: 'Your BMI indicates Class I Obesity.',
              statusColor: Colors.deepOrange,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: true,
              isDark: false,
              onBookAppointment: () {
                appointmentPressed = true;
              },
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap book appointment button
      await tester.tap(find.text('Book an Appointment'));
      await tester.pump();

      expect(appointmentPressed, true);
      expect(dismissPressed, false);

      // Reset screen size
      addTearDown(tester.view.reset);
    });

    testWidgets('i understand button triggers callback', (WidgetTester tester) async {
      bool appointmentPressed = false;
      bool dismissPressed = false;

      // Set larger screen size for this test
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '32.0',
              unit: 'kg/m²',
              category: 'Obese Class I',
              riskLevel: 'Moderate-High',
              message: 'Your BMI indicates Class I Obesity.',
              statusColor: Colors.deepOrange,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: true,
              isDark: false,
              onBookAppointment: () {
                appointmentPressed = true;
              },
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap I Understand button
      await tester.tap(find.text('I Understand'));
      await tester.pump();

      expect(appointmentPressed, false);
      expect(dismissPressed, true);

      // Reset screen size
      addTearDown(tester.view.reset);
    });

    testWidgets('close button triggers callback when no medical attention required', (WidgetTester tester) async {
      bool appointmentPressed = false;
      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '22.0',
              unit: 'kg/m²',
              category: 'Normal/Optimal',
              riskLevel: 'Low',
              message: 'Great! You have a healthy weight.',
              statusColor: Colors.green,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: false,
              isDark: false,
              onBookAppointment: () {
                appointmentPressed = true;
              },
              onDismiss: () {
                dismissPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(appointmentPressed, false);
      expect(dismissPressed, true);
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '22.0',
              unit: 'kg/m²',
              category: 'Normal/Optimal',
              riskLevel: 'Low',
              message: 'Great! You have a healthy weight.',
              statusColor: Colors.green,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: false,
              isDark: true,
              onBookAppointment: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Verify dialog renders
      expect(find.byType(HealthStatusDialog), findsOneWidget);
      expect(find.text('BMI Reading'), findsOneWidget);
    });

    testWidgets('applies correct status color to elements', (WidgetTester tester) async {
      const testColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '40.0',
              unit: 'kg/m²',
              category: 'Obese Class III',
              riskLevel: 'Very High',
              message: 'Immediate medical consultation is strongly recommended.',
              statusColor: testColor,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: true,
              isDark: false,
              onBookAppointment: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Verify dialog renders with the status color
      expect(find.byType(HealthStatusDialog), findsOneWidget);

      // Value should be displayed
      expect(find.text('40.0'), findsOneWidget);
      expect(find.text('Obese Class III'), findsOneWidget);
    });

    testWidgets('displays info icon for message section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthStatusDialog(
              title: 'BMI Reading',
              value: '22.0',
              unit: 'kg/m²',
              category: 'Normal/Optimal',
              riskLevel: 'Low',
              message: 'Great! You have a healthy weight.',
              statusColor: Colors.green,
              icon: Icons.monitor_weight,
              requiresMedicalAttention: false,
              isDark: false,
              onBookAppointment: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Verify info icon is present
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
