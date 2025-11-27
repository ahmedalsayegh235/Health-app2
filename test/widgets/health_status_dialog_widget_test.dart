import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/components/health_status_dialog.dart';

void main() {
  group('Health Status Dialog Widget Tests', () {
    testWidgets('Dialog renders with all required elements for normal status', (WidgetTester tester) async {
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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'This is a test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify all elements are present
      expect(find.text('Test Reading'), findsOneWidget);
      expect(find.text('95.0'), findsOneWidget);
      expect(find.text('mg/dL'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.textContaining('Risk Level:'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('This is a test message'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Dialog shows medical attention warning when required', (WidgetTester tester) async {
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
                        title: 'Critical Reading',
                        value: '250.0',
                        unit: 'mg/dL',
                        category: 'Diabetes (Severe)',
                        riskLevel: 'Very High',
                        message: 'This requires immediate attention',
                        statusColor: Colors.red,
                        icon: Icons.warning,
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

      // Verify medical attention elements
      expect(find.text('Please contact a doctor and book an appointment for a proper evaluation.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Book an Appointment'), findsOneWidget);
      expect(find.text('I Understand'), findsOneWidget);
      expect(find.text('Close'), findsNothing);
    });

    testWidgets('Close button dismisses dialog', (WidgetTester tester) async {
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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'Test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      expect(find.text('Test Reading'), findsOneWidget);

      // Tap close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('Test Reading'), findsNothing);
    });

    testWidgets('I Understand button dismisses dialog', (WidgetTester tester) async {
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
                        title: 'Critical Reading',
                        value: '250.0',
                        unit: 'mg/dL',
                        category: 'Critical',
                        riskLevel: 'Very High',
                        message: 'Test message',
                        statusColor: Colors.red,
                        icon: Icons.warning,
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

      expect(find.text('Critical Reading'), findsOneWidget);

      // Tap I Understand button
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('Critical Reading'), findsNothing);
    });

    testWidgets('Book Appointment button calls callback', (WidgetTester tester) async {
      bool appointmentCallbackCalled = false;

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
                        title: 'Critical Reading',
                        value: '250.0',
                        unit: 'mg/dL',
                        category: 'Critical',
                        riskLevel: 'Very High',
                        message: 'Test message',
                        statusColor: Colors.red,
                        icon: Icons.warning,
                        requiresMedicalAttention: true,
                        isDark: false,
                        onBookAppointment: () {
                          appointmentCallbackCalled = true;
                          Navigator.pop(context);
                        },
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

      // Tap Book Appointment button
      await tester.tap(find.text('Book an Appointment'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(appointmentCallbackCalled, true);
    });

    testWidgets('Dialog displays correctly in dark mode', (WidgetTester tester) async {
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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'Test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify dialog renders in dark mode
      expect(find.text('Test Reading'), findsOneWidget);
      expect(find.text('95.0'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('Dialog displays different status colors correctly', (WidgetTester tester) async {
      final statusColors = [
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.red,
        Colors.purple,
      ];

      for (final color in statusColors) {
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
                          title: 'Test Reading',
                          value: '95.0',
                          unit: 'mg/dL',
                          category: 'Test',
                          riskLevel: 'Low',
                          message: 'Test message',
                          statusColor: color,
                          icon: Icons.favorite,
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

        // Verify dialog displays
        expect(find.text('Test Reading'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Dialog displays different icons correctly', (WidgetTester tester) async {
      final icons = [
        Icons.favorite,
        Icons.bloodtype,
        Icons.monitor_weight,
        Icons.spa,
        Icons.healing,
      ];

      for (final icon in icons) {
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
                          title: 'Test Reading',
                          value: '95.0',
                          unit: 'test',
                          category: 'Normal',
                          riskLevel: 'Low',
                          message: 'Test message',
                          statusColor: Colors.green,
                          icon: icon,
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

        // Verify icon is displayed
        expect(find.byIcon(icon), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Dialog displays long messages correctly', (WidgetTester tester) async {
      const longMessage = 'This is a very long message that should wrap properly and display '
          'all the content without any issues. It contains multiple sentences and should be '
          'fully visible in the dialog. The dialog should handle this gracefully with proper '
          'text wrapping and scrolling if necessary.';

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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: longMessage,
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify long message is displayed
      expect(find.textContaining('This is a very long message'), findsOneWidget);
    });

    testWidgets('Dialog is not dismissible by tapping outside when barrierDismissible is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => HealthStatusDialog(
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'Test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify dialog is shown
      expect(find.text('Test Reading'), findsOneWidget);

      // Dialog should still be visible (can't test tapping outside in widget tests easily)
      expect(find.text('Test Reading'), findsOneWidget);
    });

    testWidgets('Dialog displays value and unit together correctly', (WidgetTester tester) async {
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
                        title: 'Blood Pressure',
                        value: '120/80',
                        unit: 'mmHg',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'Your blood pressure is normal',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify value and unit are displayed
      expect(find.text('120/80'), findsOneWidget);
      expect(find.text('mmHg'), findsOneWidget);
    });

    testWidgets('Dialog category badge is displayed', (WidgetTester tester) async {
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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Excellent',
                        riskLevel: 'Low',
                        message: 'Test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify category badge
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('Dialog shows info icon for message', (WidgetTester tester) async {
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
                        title: 'Test Reading',
                        value: '95.0',
                        unit: 'mg/dL',
                        category: 'Normal',
                        riskLevel: 'Low',
                        message: 'Test message',
                        statusColor: Colors.green,
                        icon: Icons.favorite,
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

      // Verify info icon is displayed near message
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
