import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/controllers/BMI_controller.dart';

void main() {
  group('BMI Controller - WHO Standards', () {
    group('calculateBmi', () {
      test('calculates BMI correctly for normal values', () {
        expect(BmiController.calculateBmi(70, 175), closeTo(22.86, 0.01));
      });

      test('calculates BMI correctly for different values', () {
        expect(BmiController.calculateBmi(85, 180), closeTo(26.23, 0.01));
        expect(BmiController.calculateBmi(55, 165), closeTo(20.20, 0.01));
      });

      test('returns 0 for invalid height', () {
        expect(BmiController.calculateBmi(70, 0), 0);
        expect(BmiController.calculateBmi(70, -10), 0);
      });

      test('returns 0 for invalid weight', () {
        expect(BmiController.calculateBmi(0, 175), 0);
        expect(BmiController.calculateBmi(-10, 175), 0);
      });
    });

    group('getBmiCategory - WHO Classification', () {
      test('returns correct category for severe underweight', () {
        expect(BmiController.getBmiCategory(14.0), 'Underweight (Severe)');
        expect(BmiController.getBmiCategory(14.9), 'Underweight (Severe)');
      });

      test('returns correct category for moderate underweight', () {
        expect(BmiController.getBmiCategory(15.0), 'Underweight (Moderate)');
        expect(BmiController.getBmiCategory(16.5), 'Underweight (Moderate)');
        expect(BmiController.getBmiCategory(16.9), 'Underweight (Moderate)');
      });

      test('returns correct category for mild underweight', () {
        expect(BmiController.getBmiCategory(17.0), 'Underweight (Mild)');
        expect(BmiController.getBmiCategory(18.0), 'Underweight (Mild)');
        expect(BmiController.getBmiCategory(18.4), 'Underweight (Mild)');
      });

      test('returns correct category for normal/optimal', () {
        expect(BmiController.getBmiCategory(18.5), 'Normal/Optimal');
        expect(BmiController.getBmiCategory(22.0), 'Normal/Optimal');
        expect(BmiController.getBmiCategory(24.9), 'Normal/Optimal');
      });

      test('returns correct category for overweight grade I', () {
        expect(BmiController.getBmiCategory(25.0), 'Overweight (Grade I)');
        expect(BmiController.getBmiCategory(26.5), 'Overweight (Grade I)');
        expect(BmiController.getBmiCategory(26.9), 'Overweight (Grade I)');
      });

      test('returns correct category for overweight grade II', () {
        expect(BmiController.getBmiCategory(27.0), 'Overweight (Grade II)');
        expect(BmiController.getBmiCategory(28.5), 'Overweight (Grade II)');
        expect(BmiController.getBmiCategory(29.9), 'Overweight (Grade II)');
      });

      test('returns correct category for obese class I', () {
        expect(BmiController.getBmiCategory(30.0), 'Obese Class I');
        expect(BmiController.getBmiCategory(32.5), 'Obese Class I');
        expect(BmiController.getBmiCategory(34.9), 'Obese Class I');
      });

      test('returns correct category for obese class II', () {
        expect(BmiController.getBmiCategory(35.0), 'Obese Class II');
        expect(BmiController.getBmiCategory(37.5), 'Obese Class II');
        expect(BmiController.getBmiCategory(39.9), 'Obese Class II');
      });

      test('returns correct category for obese class III', () {
        expect(BmiController.getBmiCategory(40.0), 'Obese Class III');
        expect(BmiController.getBmiCategory(45.0), 'Obese Class III');
        expect(BmiController.getBmiCategory(50.0), 'Obese Class III');
      });
    });

    group('getBmiRiskLevel - WHO Classification', () {
      test('returns correct risk level for severe underweight', () {
        expect(BmiController.getBmiRiskLevel(14.0), 'High');
        expect(BmiController.getBmiRiskLevel(14.9), 'High');
      });

      test('returns correct risk level for moderate underweight', () {
        expect(BmiController.getBmiRiskLevel(15.0), 'Moderate');
        expect(BmiController.getBmiRiskLevel(16.9), 'Moderate');
      });

      test('returns correct risk level for mild underweight', () {
        expect(BmiController.getBmiRiskLevel(17.0), 'Low-Moderate');
        expect(BmiController.getBmiRiskLevel(18.4), 'Low-Moderate');
      });

      test('returns correct risk level for normal/optimal', () {
        expect(BmiController.getBmiRiskLevel(18.5), 'Low');
        expect(BmiController.getBmiRiskLevel(24.9), 'Low');
      });

      test('returns correct risk level for overweight grade I', () {
        expect(BmiController.getBmiRiskLevel(25.0), 'Low-Moderate');
        expect(BmiController.getBmiRiskLevel(26.9), 'Low-Moderate');
      });

      test('returns correct risk level for overweight grade II', () {
        expect(BmiController.getBmiRiskLevel(27.0), 'Moderate');
        expect(BmiController.getBmiRiskLevel(29.9), 'Moderate');
      });

      test('returns correct risk level for obese class I', () {
        expect(BmiController.getBmiRiskLevel(30.0), 'Moderate-High');
        expect(BmiController.getBmiRiskLevel(34.9), 'Moderate-High');
      });

      test('returns correct risk level for obese class II', () {
        expect(BmiController.getBmiRiskLevel(35.0), 'High');
        expect(BmiController.getBmiRiskLevel(39.9), 'High');
      });

      test('returns correct risk level for obese class III', () {
        expect(BmiController.getBmiRiskLevel(40.0), 'Very High');
        expect(BmiController.getBmiRiskLevel(45.0), 'Very High');
      });
    });

    group('requiresMedicalAttention', () {
      test('returns true for severe underweight', () {
        expect(BmiController.requiresMedicalAttention(14.0), true);
        expect(BmiController.requiresMedicalAttention(16.5), true);
      });

      test('returns false for mild underweight', () {
        expect(BmiController.requiresMedicalAttention(17.0), false);
        expect(BmiController.requiresMedicalAttention(18.4), false);
      });

      test('returns false for normal/optimal', () {
        expect(BmiController.requiresMedicalAttention(18.5), false);
        expect(BmiController.requiresMedicalAttention(24.9), false);
      });

      test('returns false for overweight grades', () {
        expect(BmiController.requiresMedicalAttention(25.0), false);
        expect(BmiController.requiresMedicalAttention(29.9), false);
      });

      test('returns true for all obesity classes', () {
        expect(BmiController.requiresMedicalAttention(30.0), true);
        expect(BmiController.requiresMedicalAttention(35.0), true);
        expect(BmiController.requiresMedicalAttention(40.0), true);
        expect(BmiController.requiresMedicalAttention(45.0), true);
      });
    });

    group('getBmiCategoryColor', () {
      test('returns red for severe underweight', () {
        expect(BmiController.getBmiCategoryColor(14.0), Colors.red);
      });

      test('returns orange for moderate underweight', () {
        expect(BmiController.getBmiCategoryColor(16.0), Colors.orange);
      });

      test('returns blue for mild underweight', () {
        expect(BmiController.getBmiCategoryColor(18.0), Colors.blue);
      });

      test('returns green for normal/optimal', () {
        expect(BmiController.getBmiCategoryColor(22.0), Colors.green);
      });

      test('returns blue for overweight grade I', () {
        expect(BmiController.getBmiCategoryColor(26.0), Colors.blue);
      });

      test('returns orange for overweight grade II', () {
        expect(BmiController.getBmiCategoryColor(28.0), Colors.orange);
      });

      test('returns deepOrange for obese class I', () {
        expect(BmiController.getBmiCategoryColor(32.0), Colors.deepOrange);
      });

      test('returns red for obese class II', () {
        expect(BmiController.getBmiCategoryColor(37.0), Colors.red);
      });

      test('returns red.shade900 for obese class III', () {
        expect(BmiController.getBmiCategoryColor(42.0), Colors.red.shade900);
      });
    });

    group('getBmiAdvice', () {
      test('provides appropriate advice for severe underweight', () {
        final advice = BmiController.getBmiAdvice(14.0);
        expect(advice, contains('severe underweight'));
        expect(advice, contains('immediate medical attention'));
      });

      test('provides appropriate advice for moderate underweight', () {
        final advice = BmiController.getBmiAdvice(16.0);
        expect(advice, contains('moderate underweight'));
        expect(advice, contains('nutritionist'));
      });

      test('provides appropriate advice for mild underweight', () {
        final advice = BmiController.getBmiAdvice(18.0);
        expect(advice, contains('mildly underweight'));
        expect(advice, contains('nutritionist'));
      });

      test('provides appropriate advice for normal/optimal', () {
        final advice = BmiController.getBmiAdvice(22.0);
        expect(advice, contains('healthy weight'));
        expect(advice, contains('maintaining'));
      });

      test('provides appropriate advice for overweight grade I', () {
        final advice = BmiController.getBmiAdvice(26.0);
        expect(advice, contains('overweight'));
        expect(advice, contains('Grade I'));
      });

      test('provides appropriate advice for overweight grade II', () {
        final advice = BmiController.getBmiAdvice(28.0);
        expect(advice, contains('overweight'));
        expect(advice, contains('Grade II'));
        expect(advice, contains('healthcare professional'));
      });

      test('provides appropriate advice for obese class I', () {
        final advice = BmiController.getBmiAdvice(32.0);
        expect(advice, contains('Class I Obesity'));
        expect(advice, contains('healthcare professional'));
      });

      test('provides appropriate advice for obese class II', () {
        final advice = BmiController.getBmiAdvice(37.0);
        expect(advice, contains('Class II Obesity'));
        expect(advice, contains('Medical consultation'));
      });

      test('provides appropriate advice for obese class III', () {
        final advice = BmiController.getBmiAdvice(42.0);
        expect(advice, contains('Class III Obesity'));
        expect(advice, contains('Immediate medical consultation'));
      });
    });
  });
}
