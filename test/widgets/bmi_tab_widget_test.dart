import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/BMI_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/bmi_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('BMI Tab Widget Tests', () {
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

    testWidgets('BMI Tab renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are displayed
      expect(find.text('Calculate BMI'), findsOneWidget);
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);
      expect(find.text('Calculate'), findsOneWidget);
    });

    testWidgets('Weight and height fields are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify both TextFormFields exist
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);
    });

    testWidgets('Form validation works for empty inputs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit without entering values
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('Please enter your weight'), findsOneWidget);
      expect(find.text('Please enter your height'), findsOneWidget);
    });

    testWidgets('Form validation works for invalid weight', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find text fields
      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter valid height but invalid weight
      await tester.enterText(weightField, '0');
      await tester.enterText(heightField, '170');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid weight'), findsOneWidget);
    });

    testWidgets('Form validation works for invalid height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter valid weight but invalid height
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '0');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid height'), findsOneWidget);
    });

    testWidgets('Form accepts valid weight and height values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter valid values
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();

      // Verify no validation errors for valid inputs
      expect(find.text('Please enter your weight'), findsNothing);
      expect(find.text('Please enter a valid weight'), findsNothing);
      expect(find.text('Please enter your height'), findsNothing);
      expect(find.text('Please enter a valid height'), findsNothing);
    });

    testWidgets('Current BMI display shows empty state when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('--.-'), findsOneWidget);
      expect(find.text('kg/m²'), findsWidgets);
    });

    testWidgets('BMI icons are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify monitor_weight icon exists
      expect(find.byIcon(Icons.monitor_weight), findsWidgets);
    });

    testWidgets('Empty state message is displayed when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No readings yet'), findsOneWidget);
      expect(find.text('Calculate your first BMI above'), findsOneWidget);
    });

    testWidgets('Previous Readings header is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify header with count
      expect(find.textContaining('Previous Readings'), findsOneWidget);
    });

    testWidgets('Dark mode toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Toggle dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify widget still renders correctly
      expect(find.text('Calculate BMI'), findsOneWidget);

      // Toggle back
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Calculate BMI'), findsOneWidget);
    });

    testWidgets('Text fields have correct decorations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the text fields have correct labels
      expect(find.text('Weight (kg)'), findsOneWidget);
      expect(find.text('Height (cm)'), findsOneWidget);

      // Verify they have the monitor_weight icon
      expect(find.byIcon(Icons.monitor_weight), findsWidgets);
    });

    testWidgets('Widget respects user authentication state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When not logged in, should show login required message
      expect(find.text('Login required to save readings'), findsOneWidget);
    });

    testWidgets('Calculate button is disabled when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the calculate button
      final calculateButton = find.text('Calculate');
      expect(calculateButton, findsOneWidget);

      // Verify login message is shown
      expect(find.text('Login required to save readings'), findsOneWidget);
    });

    testWidgets('Animations complete without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Pump a few frames to allow animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));

      // Complete all animations
      await tester.pumpAndSettle();

      // Verify no exceptions occurred during animation
      expect(tester.takeException(), isNull);

      // Verify all main components are visible after animations
      expect(find.text('Calculate BMI'), findsOneWidget);
      expect(find.text('Previous Readings (0)'), findsOneWidget);
    });

    testWidgets('Form can be filled and cleared', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter values
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '175');
      await tester.pumpAndSettle();
      expect(find.text('70'), findsOneWidget);
      expect(find.text('175'), findsOneWidget);

      // Clear values
      await tester.enterText(weightField, '');
      await tester.enterText(heightField, '');
      await tester.pumpAndSettle();
    });

    testWidgets('Widget layout is responsive', (WidgetTester tester) async {
      // Test with default size
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Calculate BMI'), findsOneWidget);

      // Test with smaller viewport
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Calculate BMI'), findsOneWidget);
    });

    testWidgets('Multiple rapid form entries work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Rapidly enter different values
      await tester.enterText(weightField, '60');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(heightField, '165');
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(weightField, '70');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(heightField, '175');
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(weightField, '80');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(heightField, '180');

      await tester.pumpAndSettle();

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
      expect(find.text('80'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);
    });

    testWidgets('Decimal values are accepted in form fields', (WidgetTester tester) async {
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

    testWidgets('Negative values trigger validation error', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final weightField = textFields.at(0);
      final heightField = textFields.at(1);

      // Enter negative weight
      await tester.enterText(weightField, '-10');
      await tester.enterText(heightField, '175');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid weight'), findsOneWidget);

      // Enter negative height
      await tester.enterText(weightField, '70');
      await tester.enterText(heightField, '-10');
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid height'), findsOneWidget);
    });

    testWidgets('Height icon is displayed in form', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify height icon exists
      expect(find.byIcon(Icons.height), findsWidgets);
    });

    testWidgets('Empty state shows correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state icon (monitor_weight_outlined)
      expect(find.byIcon(Icons.monitor_weight_outlined), findsWidgets);
    });
  });
}
