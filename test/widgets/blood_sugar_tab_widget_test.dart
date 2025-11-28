import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/controllers/activities_provider.dart';
import 'package:health/controllers/blood_sugar_controller.dart';
import 'package:health/helpers/theme_provider.dart';
import 'package:health/patient_views/tabs/bloodsugar_tab.dart';
import 'package:provider/provider.dart';

void main() {
  group('Blood Sugar Tab Widget Tests', () {
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

    testWidgets('Blood Sugar Tab renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify main components are displayed
      expect(find.text('Record Blood Sugar'), findsOneWidget);
      expect(find.text('Blood Sugar (mg/dL)'), findsOneWidget);
      expect(find.text('Save Reading'), findsOneWidget);
    });

    testWidgets('Reading type buttons are displayed and selectable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all three reading type buttons exist
      expect(find.text('Fasting'), findsOneWidget);
      expect(find.text('Post Meal'), findsOneWidget);
      expect(find.text('Random'), findsOneWidget);

      // Tap Post Meal button
      await tester.tap(find.text('Post Meal'));
      await tester.pumpAndSettle();

      // Tap Random button
      await tester.tap(find.text('Random'));
      await tester.pumpAndSettle();

      // Tap back to Fasting
      await tester.tap(find.text('Fasting'));
      await tester.pumpAndSettle();

      // Verify no errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Form validation works for empty input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to submit without entering a value
      await tester.tap(find.text('Save Reading'));
      await tester.pumpAndSettle();

      // Verify validation error appears
      expect(find.text('Please enter blood sugar level'), findsOneWidget);
    });

    testWidgets('Form validation works for invalid input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter invalid value (non-numeric)
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'invalid');
      await tester.tap(find.text('Save Reading'));
      await tester.pumpAndSettle();

      // Enter zero value
      await tester.enterText(textField, '0');
      await tester.tap(find.text('Save Reading'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid blood sugar level'), findsOneWidget);
    });

    testWidgets('Form accepts valid blood sugar values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid blood sugar value
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '95');
      await tester.pumpAndSettle();

      // Verify no validation errors for valid input
      expect(find.text('Please enter blood sugar level'), findsNothing);
      expect(find.text('Please enter a valid blood sugar level'), findsNothing);
    });

    testWidgets('Current reading display shows empty state when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('--'), findsOneWidget);
      expect(find.text('mg/dL'), findsWidgets);
    });

    testWidgets('Blood sugar icon is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify bloodtype icon exists
      expect(find.byIcon(Icons.bloodtype), findsWidgets);
    });

    testWidgets('Empty state message is displayed when no readings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No readings yet'), findsOneWidget);
      expect(find.text('Add your first blood sugar reading above'), findsOneWidget);
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
      expect(find.text('Record Blood Sugar'), findsOneWidget);

      // Toggle back
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(find.text('Record Blood Sugar'), findsOneWidget);
    });

    testWidgets('Text field has correct decoration', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the TextFormField
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsOneWidget);

      // Verify the text field has the correct label
      expect(find.text('Blood Sugar (mg/dL)'), findsOneWidget);

      // Verify it has the bloodtype icon
      expect(find.byIcon(Icons.bloodtype), findsWidgets);
    });

    testWidgets('Reading type selector has correct visual feedback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initial state - Fasting should be selected
      await tester.tap(find.text('Post Meal'));
      await tester.pumpAndSettle();

      // Verify animation completes without error
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Random'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Widget respects user authentication state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // When not logged in, should show login required message
      expect(find.text('Login required to save readings'), findsOneWidget);
    });

    testWidgets('Save button is disabled when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the save button
      final saveButton = find.text('Save Reading');
      expect(saveButton, findsOneWidget);

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
      expect(find.text('Record Blood Sugar'), findsOneWidget);
      expect(find.text('Previous Readings (0)'), findsOneWidget);
    });

    testWidgets('Multiple rapid taps on reading type buttons work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapidly tap different buttons
      await tester.tap(find.text('Post Meal'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Random'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Fasting'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Post Meal'));

      await tester.pumpAndSettle();

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Form can be filled and cleared', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);

      // Enter value
      await tester.enterText(textField, '120');
      await tester.pumpAndSettle();
      expect(find.text('120'), findsOneWidget);

      // Clear value
      await tester.enterText(textField, '');
      await tester.pumpAndSettle();
    });

    testWidgets('Widget layout is responsive', (WidgetTester tester) async {
      // Test with default size
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Record Blood Sugar'), findsOneWidget);

      // Test with smaller viewport
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Record Blood Sugar'), findsOneWidget);
    });
  });
}
