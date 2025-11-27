import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/controllers/blood_sugar_controller.dart';

void main() {
  group('Blood Sugar Controller - ADA Standards', () {
    group('getBloodSugarCategory - Fasting', () {
      test('returns correct category for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarCategory(60, 'fasting'), 'Hypoglycemia');
        expect(BloodSugarController.getBloodSugarCategory(69, 'fasting'), 'Hypoglycemia');
      });

      test('returns correct category for normal fasting', () {
        expect(BloodSugarController.getBloodSugarCategory(70, 'fasting'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(85, 'fasting'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(99, 'fasting'), 'Normal');
      });

      test('returns correct category for prediabetes low', () {
        expect(BloodSugarController.getBloodSugarCategory(100, 'fasting'), 'Prediabetes (Low)');
        expect(BloodSugarController.getBloodSugarCategory(109, 'fasting'), 'Prediabetes (Low)');
      });

      test('returns correct category for prediabetes high', () {
        expect(BloodSugarController.getBloodSugarCategory(110, 'fasting'), 'Prediabetes (High)');
        expect(BloodSugarController.getBloodSugarCategory(125, 'fasting'), 'Prediabetes (High)');
      });

      test('returns correct category for diabetes mild', () {
        expect(BloodSugarController.getBloodSugarCategory(126, 'fasting'), 'Diabetes (Mild)');
        expect(BloodSugarController.getBloodSugarCategory(150, 'fasting'), 'Diabetes (Mild)');
      });

      test('returns correct category for diabetes moderate', () {
        expect(BloodSugarController.getBloodSugarCategory(151, 'fasting'), 'Diabetes (Moderate)');
        expect(BloodSugarController.getBloodSugarCategory(200, 'fasting'), 'Diabetes (Moderate)');
      });

      test('returns correct category for diabetes severe', () {
        expect(BloodSugarController.getBloodSugarCategory(201, 'fasting'), 'Diabetes (Severe)');
        expect(BloodSugarController.getBloodSugarCategory(300, 'fasting'), 'Diabetes (Severe)');
      });
    });

    group('getBloodSugarCategory - Post Meal', () {
      test('returns correct category for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarCategory(60, 'post_meal'), 'Hypoglycemia');
        expect(BloodSugarController.getBloodSugarCategory(69, 'post_meal'), 'Hypoglycemia');
      });

      test('returns correct category for normal post-meal', () {
        expect(BloodSugarController.getBloodSugarCategory(70, 'post_meal'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(120, 'post_meal'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(139, 'post_meal'), 'Normal');
      });

      test('returns correct category for slightly elevated', () {
        expect(BloodSugarController.getBloodSugarCategory(140, 'post_meal'), 'Slightly Elevated');
        expect(BloodSugarController.getBloodSugarCategory(179, 'post_meal'), 'Slightly Elevated');
      });

      test('returns correct category for high', () {
        expect(BloodSugarController.getBloodSugarCategory(180, 'post_meal'), 'High');
        expect(BloodSugarController.getBloodSugarCategory(199, 'post_meal'), 'High');
      });

      test('returns correct category for very high', () {
        expect(BloodSugarController.getBloodSugarCategory(200, 'post_meal'), 'Very High');
        expect(BloodSugarController.getBloodSugarCategory(250, 'post_meal'), 'Very High');
      });
    });

    group('getBloodSugarCategory - Random', () {
      test('returns correct category for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarCategory(60, 'random'), 'Hypoglycemia');
        expect(BloodSugarController.getBloodSugarCategory(69, 'random'), 'Hypoglycemia');
      });

      test('returns correct category for normal random', () {
        expect(BloodSugarController.getBloodSugarCategory(70, 'random'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(120, 'random'), 'Normal');
        expect(BloodSugarController.getBloodSugarCategory(139, 'random'), 'Normal');
      });

      test('returns correct category for elevated', () {
        expect(BloodSugarController.getBloodSugarCategory(140, 'random'), 'Elevated');
        expect(BloodSugarController.getBloodSugarCategory(199, 'random'), 'Elevated');
      });

      test('returns correct category for very high', () {
        expect(BloodSugarController.getBloodSugarCategory(200, 'random'), 'Very High');
        expect(BloodSugarController.getBloodSugarCategory(250, 'random'), 'Very High');
      });
    });

    group('getBloodSugarRiskLevel - Fasting', () {
      test('returns correct risk level for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(65, 'fasting'), 'Moderate-High');
      });

      test('returns correct risk level for normal', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(85, 'fasting'), 'Low');
      });

      test('returns correct risk level for prediabetes low', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(105, 'fasting'), 'Low-Moderate');
      });

      test('returns correct risk level for prediabetes high', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(115, 'fasting'), 'Moderate');
      });

      test('returns correct risk level for diabetes mild', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(135, 'fasting'), 'Moderate-High');
      });

      test('returns correct risk level for diabetes moderate', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(175, 'fasting'), 'High');
      });

      test('returns correct risk level for diabetes severe', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(250, 'fasting'), 'Very High');
      });
    });

    group('getBloodSugarRiskLevel - Post Meal', () {
      test('returns correct risk level for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(65, 'post_meal'), 'Moderate-High');
      });

      test('returns correct risk level for normal', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(120, 'post_meal'), 'Low');
      });

      test('returns correct risk level for slightly elevated', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(160, 'post_meal'), 'Low-Moderate');
      });

      test('returns correct risk level for high', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(190, 'post_meal'), 'Moderate');
      });

      test('returns correct risk level for very high', () {
        expect(BloodSugarController.getBloodSugarRiskLevel(220, 'post_meal'), 'High');
      });
    });

    group('requiresMedicalAttention', () {
      test('returns true for hypoglycemia in all types', () {
        expect(BloodSugarController.requiresMedicalAttention(65, 'fasting'), true);
        expect(BloodSugarController.requiresMedicalAttention(65, 'post_meal'), true);
        expect(BloodSugarController.requiresMedicalAttention(65, 'random'), true);
      });

      test('returns false for normal fasting', () {
        expect(BloodSugarController.requiresMedicalAttention(85, 'fasting'), false);
      });

      test('returns false for prediabetes', () {
        expect(BloodSugarController.requiresMedicalAttention(105, 'fasting'), false);
        expect(BloodSugarController.requiresMedicalAttention(120, 'fasting'), false);
      });

      test('returns true for diabetes range in fasting', () {
        expect(BloodSugarController.requiresMedicalAttention(126, 'fasting'), true);
        expect(BloodSugarController.requiresMedicalAttention(150, 'fasting'), true);
        expect(BloodSugarController.requiresMedicalAttention(200, 'fasting'), true);
      });

      test('returns false for normal and elevated post-meal', () {
        expect(BloodSugarController.requiresMedicalAttention(120, 'post_meal'), false);
        expect(BloodSugarController.requiresMedicalAttention(160, 'post_meal'), false);
        expect(BloodSugarController.requiresMedicalAttention(190, 'post_meal'), false);
      });

      test('returns true for very high post-meal', () {
        expect(BloodSugarController.requiresMedicalAttention(200, 'post_meal'), true);
        expect(BloodSugarController.requiresMedicalAttention(250, 'post_meal'), true);
      });

      test('returns true for very high random', () {
        expect(BloodSugarController.requiresMedicalAttention(200, 'random'), true);
        expect(BloodSugarController.requiresMedicalAttention(250, 'random'), true);
      });
    });

    group('getBloodSugarCategoryColor', () {
      test('returns red for hypoglycemia', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(65, 'fasting'), Colors.red);
        expect(BloodSugarController.getBloodSugarCategoryColor(65, 'post_meal'), Colors.red);
        expect(BloodSugarController.getBloodSugarCategoryColor(65, 'random'), Colors.red);
      });

      test('returns green for normal fasting', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(85, 'fasting'), Colors.green);
      });

      test('returns blue for prediabetes low', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(105, 'fasting'), Colors.blue);
      });

      test('returns orange for prediabetes high', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(115, 'fasting'), Colors.orange);
      });

      test('returns deepOrange for diabetes mild', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(135, 'fasting'), Colors.deepOrange);
      });

      test('returns red for diabetes moderate', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(175, 'fasting'), Colors.red);
      });

      test('returns red.shade900 for diabetes severe', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(250, 'fasting'), Colors.red.shade900);
      });

      test('returns green for normal post-meal', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(120, 'post_meal'), Colors.green);
      });

      test('returns blue for slightly elevated post-meal', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(160, 'post_meal'), Colors.blue);
      });

      test('returns orange for high post-meal', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(190, 'post_meal'), Colors.orange);
      });

      test('returns red for very high post-meal', () {
        expect(BloodSugarController.getBloodSugarCategoryColor(220, 'post_meal'), Colors.red);
      });
    });

    group('getBloodSugarAdvice', () {
      test('provides appropriate advice for hypoglycemia', () {
        final advice = BloodSugarController.getBloodSugarAdvice(65, 'fasting');
        expect(advice, contains('hypoglycemia'));
        expect(advice, contains('15-20g'));
        expect(advice, contains('fast-acting carbohydrates'));
      });

      test('provides appropriate advice for normal fasting', () {
        final advice = BloodSugarController.getBloodSugarAdvice(85, 'fasting');
        expect(advice, contains('normal range'));
        expect(advice, contains('healthy lifestyle'));
      });

      test('provides appropriate advice for prediabetes low', () {
        final advice = BloodSugarController.getBloodSugarAdvice(105, 'fasting');
        expect(advice, contains('prediabetes'));
        expect(advice, contains('Lifestyle changes'));
      });

      test('provides appropriate advice for prediabetes high', () {
        final advice = BloodSugarController.getBloodSugarAdvice(115, 'fasting');
        expect(advice, contains('prediabetes'));
        expect(advice, contains('healthcare provider'));
      });

      test('provides appropriate advice for diabetes mild', () {
        final advice = BloodSugarController.getBloodSugarAdvice(135, 'fasting');
        expect(advice, contains('mild diabetes'));
        expect(advice, contains('Medical consultation'));
      });

      test('provides appropriate advice for diabetes moderate', () {
        final advice = BloodSugarController.getBloodSugarAdvice(175, 'fasting');
        expect(advice, contains('moderate diabetes'));
        expect(advice, contains('Immediate medical consultation'));
      });

      test('provides appropriate advice for diabetes severe', () {
        final advice = BloodSugarController.getBloodSugarAdvice(250, 'fasting');
        expect(advice, contains('severe diabetes'));
        expect(advice, contains('Urgent medical consultation'));
      });

      test('provides appropriate advice for normal post-meal', () {
        final advice = BloodSugarController.getBloodSugarAdvice(120, 'post_meal');
        expect(advice, contains('normal range'));
        expect(advice, contains('eating habits'));
      });

      test('provides appropriate advice for slightly elevated post-meal', () {
        final advice = BloodSugarController.getBloodSugarAdvice(160, 'post_meal');
        expect(advice, contains('slightly elevated'));
        expect(advice, contains('meal portions'));
      });

      test('provides appropriate advice for high post-meal', () {
        final advice = BloodSugarController.getBloodSugarAdvice(190, 'post_meal');
        expect(advice, contains('high'));
        expect(advice, contains('healthcare provider'));
      });

      test('provides appropriate advice for very high post-meal', () {
        final advice = BloodSugarController.getBloodSugarAdvice(220, 'post_meal');
        expect(advice, contains('very high'));
        expect(advice, contains('Medical consultation'));
      });

      test('provides appropriate advice for normal random', () {
        final advice = BloodSugarController.getBloodSugarAdvice(120, 'random');
        expect(advice, contains('normal range'));
      });

      test('provides appropriate advice for elevated random', () {
        final advice = BloodSugarController.getBloodSugarAdvice(170, 'random');
        expect(advice, contains('elevated'));
      });

      test('provides appropriate advice for very high random', () {
        final advice = BloodSugarController.getBloodSugarAdvice(220, 'random');
        expect(advice, contains('very high'));
      });
    });
  });
}
