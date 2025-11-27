import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/helpers/app_theme.dart';
import 'package:health/helpers/tab_helper.dart';

void main() {
  group('Heart Rate Helper Functions Tests', () {
    group('getHeartRateCategory', () {
      test('returns "Bradycardia" for values < 40', () {
        expect(getHeartRateCategory(35), 'Bradycardia');
        expect(getHeartRateCategory(39), 'Bradycardia');
      });

      test('returns "Very Low" for values 40-49', () {
        expect(getHeartRateCategory(40), 'Very Low');
        expect(getHeartRateCategory(45), 'Very Low');
        expect(getHeartRateCategory(49), 'Very Low');
      });

      test('returns "Athletic/Low" for values 50-59', () {
        expect(getHeartRateCategory(50), 'Athletic/Low');
        expect(getHeartRateCategory(55), 'Athletic/Low');
        expect(getHeartRateCategory(59), 'Athletic/Low');
      });

      test('returns "Optimal" for values 60-80', () {
        expect(getHeartRateCategory(60), 'Optimal');
        expect(getHeartRateCategory(70), 'Optimal');
        expect(getHeartRateCategory(80), 'Optimal');
      });

      test('returns "Slightly Elevated" for values 81-90', () {
        expect(getHeartRateCategory(81), 'Slightly Elevated');
        expect(getHeartRateCategory(85), 'Slightly Elevated');
        expect(getHeartRateCategory(90), 'Slightly Elevated');
      });

      test('returns "Elevated" for values 91-100', () {
        expect(getHeartRateCategory(91), 'Elevated');
        expect(getHeartRateCategory(95), 'Elevated');
        expect(getHeartRateCategory(100), 'Elevated');
      });

      test('returns "High" for values 101-110', () {
        expect(getHeartRateCategory(101), 'High');
        expect(getHeartRateCategory(105), 'High');
        expect(getHeartRateCategory(110), 'High');
      });

      test('returns "Very High" for values 111-130', () {
        expect(getHeartRateCategory(111), 'Very High');
        expect(getHeartRateCategory(120), 'Very High');
        expect(getHeartRateCategory(130), 'Very High');
      });

      test('returns "Dangerous" for values > 130', () {
        expect(getHeartRateCategory(131), 'Dangerous');
        expect(getHeartRateCategory(150), 'Dangerous');
        expect(getHeartRateCategory(200), 'Dangerous');
      });
    });

    group('getHeartRateRiskLevel', () {
      test('returns correct risk levels for all ranges', () {
        expect(getHeartRateRiskLevel(35), 'High');
        expect(getHeartRateRiskLevel(45), 'Moderate');
        expect(getHeartRateRiskLevel(55), 'Low');
        expect(getHeartRateRiskLevel(70), 'Low');
        expect(getHeartRateRiskLevel(85), 'Low-Moderate');
        expect(getHeartRateRiskLevel(95), 'Moderate');
        expect(getHeartRateRiskLevel(105), 'Moderate-High');
        expect(getHeartRateRiskLevel(120), 'High');
        expect(getHeartRateRiskLevel(150), 'Very High');
      });
    });

    group('getHeartStatusColor', () {
      test('returns correct colors for all ranges', () {
        expect(getHeartStatusColor(35), Colors.red);
        expect(getHeartStatusColor(45), Colors.orange);
        expect(getHeartStatusColor(55), Colors.blue);
        expect(getHeartStatusColor(70), AppTheme.lightgreen);
        expect(getHeartStatusColor(85), Colors.orange);
        expect(getHeartStatusColor(95), Colors.deepOrange);
        expect(getHeartStatusColor(105), Colors.red);
        expect(getHeartStatusColor(120), Colors.red.shade900);
      });
    });

    group('requiresHeartRateMedicalAttention', () {
      test('returns true for values < 50', () {
        expect(requiresHeartRateMedicalAttention(30), true);
        expect(requiresHeartRateMedicalAttention(45), true);
        expect(requiresHeartRateMedicalAttention(49), true);
      });

      test('returns false for normal values 50-110', () {
        expect(requiresHeartRateMedicalAttention(50), false);
        expect(requiresHeartRateMedicalAttention(70), false);
        expect(requiresHeartRateMedicalAttention(100), false);
        expect(requiresHeartRateMedicalAttention(110), false);
      });

      test('returns true for values > 110', () {
        expect(requiresHeartRateMedicalAttention(111), true);
        expect(requiresHeartRateMedicalAttention(120), true);
        expect(requiresHeartRateMedicalAttention(150), true);
      });
    });

    group('getHeartRateAdvice', () {
      test('returns appropriate advice for bradycardia', () {
        final advice = getHeartRateAdvice(35);
        expect(advice.contains('critically low'), true);
        expect(advice.contains('bradycardia'), true);
      });

      test('returns appropriate advice for optimal range', () {
        final advice = getHeartRateAdvice(70);
        expect(advice.contains('optimal'), true);
        expect(advice.contains('improved cardiovascular outcomes'), true);
      });

      test('returns appropriate advice for dangerous range', () {
        final advice = getHeartRateAdvice(150);
        expect(advice.contains('dangerously high'), true);
        expect(advice.contains('immediate medical attention'), true);
      });
    });
  });

  group('SpO2 Helper Functions Tests', () {
    group('getSPo2Category', () {
      test('returns "Critical Hypoxemia" for values < 85', () {
        expect(getSPo2Category(80), 'Critical Hypoxemia');
        expect(getSPo2Category(84), 'Critical Hypoxemia');
      });

      test('returns "Severe Hypoxemia" for values 85-87', () {
        expect(getSPo2Category(85), 'Severe Hypoxemia');
        expect(getSPo2Category(86), 'Severe Hypoxemia');
        expect(getSPo2Category(87), 'Severe Hypoxemia');
      });

      test('returns "Moderate Hypoxemia" for values 88-91', () {
        expect(getSPo2Category(88), 'Moderate Hypoxemia');
        expect(getSPo2Category(90), 'Moderate Hypoxemia');
        expect(getSPo2Category(91), 'Moderate Hypoxemia');
      });

      test('returns "Mild Hypoxemia" for values 92-94', () {
        expect(getSPo2Category(92), 'Mild Hypoxemia');
        expect(getSPo2Category(93), 'Mild Hypoxemia');
        expect(getSPo2Category(94), 'Mild Hypoxemia');
      });

      test('returns "Low Normal" for value 95', () {
        expect(getSPo2Category(95), 'Low Normal');
      });

      test('returns "Normal" for values 96-97', () {
        expect(getSPo2Category(96), 'Normal');
        expect(getSPo2Category(97), 'Normal');
      });

      test('returns "Optimal" for values 98-99', () {
        expect(getSPo2Category(98), 'Optimal');
        expect(getSPo2Category(99), 'Optimal');
      });

      test('returns "Possibly Artifact" for value 100', () {
        expect(getSPo2Category(100), 'Possibly Artifact');
      });
    });

    group('getSPo2RiskLevel', () {
      test('returns correct risk levels for all ranges', () {
        expect(getSPo2RiskLevel(80), 'Critical');
        expect(getSPo2RiskLevel(86), 'High');
        expect(getSPo2RiskLevel(90), 'Moderate-High');
        expect(getSPo2RiskLevel(93), 'Moderate');
        expect(getSPo2RiskLevel(95), 'Low');
        expect(getSPo2RiskLevel(98), 'Low');
        expect(getSPo2RiskLevel(100), 'Low');
      });
    });

    group('getSPo2StatusColor', () {
      test('returns correct colors for all ranges', () {
        expect(getSPo2StatusColor(80), Colors.red.shade900);
        expect(getSPo2StatusColor(86), Colors.red);
        expect(getSPo2StatusColor(90), Colors.deepOrange);
        expect(getSPo2StatusColor(93), Colors.orange);
        expect(getSPo2StatusColor(95), Colors.lightGreen);
        expect(getSPo2StatusColor(96), Colors.green);
        expect(getSPo2StatusColor(98), AppTheme.lightgreen);
        expect(getSPo2StatusColor(100), Colors.blue);
      });
    });

    group('requiresSPo2MedicalAttention', () {
      test('returns true for values < 95', () {
        expect(requiresSPo2MedicalAttention(80), true);
        expect(requiresSPo2MedicalAttention(90), true);
        expect(requiresSPo2MedicalAttention(94), true);
      });

      test('returns false for values >= 95', () {
        expect(requiresSPo2MedicalAttention(95), false);
        expect(requiresSPo2MedicalAttention(98), false);
        expect(requiresSPo2MedicalAttention(100), false);
      });
    });

    group('getSPo2Advice', () {
      test('returns appropriate advice for critical hypoxemia', () {
        final advice = getSPo2Advice(80);
        expect(advice.contains('critically low'), true);
        expect(advice.contains('medical emergency'), true);
      });

      test('returns appropriate advice for optimal range', () {
        final advice = getSPo2Advice(98);
        expect(advice.contains('optimal'), true);
        expect(advice.contains('healthy respiratory function'), true);
      });

      test('returns appropriate advice for possible artifact', () {
        final advice = getSPo2Advice(100);
        expect(advice.contains('artifact'), true);
      });
    });
  });

  group('ECG Heart Rate Helper Functions Tests', () {
    group('getECGHeartRateCategory', () {
      test('uses same classification as regular heart rate', () {
        expect(getECGHeartRateCategory(70), getHeartRateCategory(70));
        expect(getECGHeartRateCategory(120), getHeartRateCategory(120));
      });
    });

    group('requiresECGMedicalAttention', () {
      test('has same thresholds as regular heart rate', () {
        expect(requiresECGMedicalAttention(45), true);
        expect(requiresECGMedicalAttention(70), false);
        expect(requiresECGMedicalAttention(120), true);
      });
    });

    group('getECGHeartRateAdvice', () {
      test('includes ECG-specific information', () {
        final advice = getECGHeartRateAdvice(70);
        expect(advice.contains('ECG'), true);
        expect(advice.contains('rhythm'), true);
      });

      test('provides appropriate advice for different ranges', () {
        final lowAdvice = getECGHeartRateAdvice(35);
        expect(lowAdvice.contains('ECG rhythm should be reviewed'), true);

        final optimalAdvice = getECGHeartRateAdvice(70);
        expect(optimalAdvice.contains('optimal'), true);

        final highAdvice = getECGHeartRateAdvice(140);
        expect(highAdvice.contains('dangerously high'), true);
      });
    });

    group('getECGRhythmAdvice', () {
      test('returns correct advice for normal sinus rhythm', () {
        final advice = getECGRhythmAdvice('Normal Sinus Rhythm');
        expect(advice.contains('normal'), true);
        expect(advice.contains('healthy rhythm pattern'), true);
      });

      test('returns correct advice for bradycardia', () {
        final advice = getECGRhythmAdvice('Bradycardia');
        expect(advice.contains('slower than normal'), true);
      });

      test('returns correct advice for tachycardia', () {
        final advice = getECGRhythmAdvice('Tachycardia');
        expect(advice.contains('faster than normal'), true);
      });

      test('returns correct advice for irregular rhythm', () {
        final advice = getECGRhythmAdvice('Irregular Rhythm');
        expect(advice.contains('irregular'), true);
        expect(advice.contains('arrhythmia'), true);
      });

      test('returns correct advice for poor signal quality', () {
        final advice = getECGRhythmAdvice('Poor Signal Quality');
        expect(advice.contains('signal quality'), true);
        expect(advice.contains('retake'), true);
      });
    });

    group('requiresECGRhythmMedicalAttention', () {
      test('returns true for concerning rhythms', () {
        expect(requiresECGRhythmMedicalAttention('Bradycardia'), true);
        expect(requiresECGRhythmMedicalAttention('Tachycardia'), true);
        expect(requiresECGRhythmMedicalAttention('Irregular Rhythm'), true);
      });

      test('returns false for normal rhythms', () {
        expect(requiresECGRhythmMedicalAttention('Normal Sinus Rhythm'), false);
        expect(requiresECGRhythmMedicalAttention('Poor Signal Quality'), false);
      });

      test('is case insensitive', () {
        expect(requiresECGRhythmMedicalAttention('bradycardia'), true);
        expect(requiresECGRhythmMedicalAttention('TACHYCARDIA'), true);
      });
    });
  });

  group('Utility Helper Functions Tests', () {
    group('formatTime', () {
      test('returns "Xm ago" for times less than an hour', () {
        final time = DateTime.now().subtract(const Duration(minutes: 30));
        expect(formatTime(time), '30m ago');
      });

      test('returns "Xh ago" for times less than a day', () {
        final time = DateTime.now().subtract(const Duration(hours: 5));
        expect(formatTime(time), '5h ago');
      });

      test('returns "Xd ago" for times more than a day', () {
        final time = DateTime.now().subtract(const Duration(days: 3));
        expect(formatTime(time), '3d ago');
      });
    });

    group('getIconData', () {
      test('returns correct icons for known types', () {
        expect(getIconData('heart'), Icons.favorite);
        expect(getIconData('spo2'), Icons.air);
        expect(getIconData('ecg'), Icons.favorite_border);
        expect(getIconData('scale'), Icons.monitor_weight_rounded);
        expect(getIconData('bloodtype'), Icons.bloodtype);
      });

      test('returns fallback icon for unknown types', () {
        expect(getIconData('unknown'), Icons.help);
      });

      test('is case insensitive', () {
        expect(getIconData('HEART'), Icons.favorite);
        expect(getIconData('Heart'), Icons.favorite);
      });
    });
  });

  group('Edge Cases and Boundary Tests', () {
    test('Heart Rate handles boundary values correctly', () {
      expect(getHeartRateCategory(40), 'Very Low');
      expect(getHeartRateCategory(50), 'Athletic/Low');
      expect(getHeartRateCategory(60), 'Optimal');
      expect(getHeartRateCategory(80), 'Optimal');
      expect(getHeartRateCategory(81), 'Slightly Elevated');
    });

    test('SpO2 handles boundary values correctly', () {
      expect(getSPo2Category(85), 'Severe Hypoxemia');
      expect(getSPo2Category(88), 'Moderate Hypoxemia');
      expect(getSPo2Category(92), 'Mild Hypoxemia');
      expect(getSPo2Category(95), 'Low Normal');
      expect(getSPo2Category(96), 'Normal');
    });

    test('All functions handle extreme values without crashing', () {
      expect(() => getHeartRateCategory(0), returnsNormally);
      expect(() => getHeartRateCategory(300), returnsNormally);
      expect(() => getSPo2Category(0), returnsNormally);
      expect(() => getSPo2Category(150), returnsNormally);
    });
  });
}
