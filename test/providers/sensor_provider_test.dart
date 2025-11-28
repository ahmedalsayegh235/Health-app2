import 'package:flutter_test/flutter_test.dart';
import 'package:health/controllers/sensor_provider.dart';
import 'package:health/models/sensor_model.dart';
import 'package:health/models/user_model.dart';

void main() {
  group('Sensor Provider Unit Tests', () {
    late SensorProvider sensorProvider;

    setUp(() {
      // Initialize user model to prevent null errors
      UserModel.userData = UserModel(
        id: 'test_user_id',
        name: 'Test User',
        email: 'test@example.com',
        cpr: '123456789',
        gender: 'Male',
        role: 'patient',
      );

      sensorProvider = SensorProvider();
    });

    tearDown(() {
      sensorProvider.dispose();
    });

    group('Initialization', () {
      test('initializes with default values', () {
        expect(sensorProvider.latest.heartRate, 0);
        expect(sensorProvider.latest.spo2, 0);
        expect(sensorProvider.isEcgRecording, false);
        expect(sensorProvider.currentMode, 'hr_spo2');
        expect(sensorProvider.realTimeEcgData, isEmpty);
      });

      test('provides access to latest sensor data', () {
        expect(sensorProvider.latest, isA<SensorData>());
        expect(sensorProvider.latest.heartRate, isA<double>());
        expect(sensorProvider.latest.spo2, isA<int>());
      });
    });

    group('ECG Mode', () {
      test('reports ECG mode correctly', () {
        expect(sensorProvider.isEcgMode, false);
        expect(sensorProvider.currentMode, 'hr_spo2');
      });

      test('ECG recording progress is initially zero', () {
        expect(sensorProvider.ecgRecordingProgress, 0.0);
      });

      test('has access to realtime BPM and rhythm', () {
        expect(sensorProvider.realtimeBPM, isA<double>());
        expect(sensorProvider.realtimeRhythm, isA<String>());
      });
    });

    group('Collection Management', () {
      test('starts heart rate collection', () {
        sensorProvider.startCollection('heart_rate');
        // Should not throw
      });

      test('starts SpO2 collection', () {
        sensorProvider.startCollection('spo2');
        // Should not throw
      });

      test('starts ECG recording', () {
        sensorProvider.startCollection('ecg');
        expect(sensorProvider.isEcgRecording, true);
      });

      test('ignores invalid collection types', () {
        sensorProvider.startCollection('invalid_type');
        expect(sensorProvider.isEcgRecording, false);
      });
    });

    group('Latest Readings', () {
      test('provides access to last heart rate reading', () {
        expect(sensorProvider.lastHeartRate, isNull);
      });

      test('provides access to last SpO2 reading', () {
        expect(sensorProvider.lastSpo2, isNull);
      });

      test('provides access to last ECG reading', () {
        expect(sensorProvider.lastEcgReading, isNull);
      });
    });

    group('Real-time ECG Buffer', () {
      test('real-time ECG buffer is unmodifiable', () {
        final buffer = sensorProvider.realTimeEcgData;
        expect(buffer, isA<List<double>>());
        expect(() => buffer.add(1.0), throwsUnsupportedError);
      });

      test('provides immutable view of real-time data', () {
        final data = sensorProvider.realTimeEcgData;
        expect(data, isEmpty);
        expect(data, isA<List<double>>());
      });
    });

    group('User ID', () {
      test('returns user ID when user is set', () {
        expect(sensorProvider.userId, 'test_user_id');
      });
    });

    group('Constants', () {
      test('ECG constants are defined correctly', () {
        expect(SensorProvider.ECG_SAMPLE_RATE, 250.0);
        expect(SensorProvider.RECORDING_DURATION, 30.0);
        expect(SensorProvider.EXPECTED_SAMPLES, 7500);
        expect(SensorProvider.MIN_SIGNAL_QUALITY, 0.7);
      });
    });
  });

  group('Sensor Provider Listener Tests', () {
    late SensorProvider sensorProvider;
    late bool listenerCalled;

    setUp(() {
      UserModel.userData = UserModel(
        id: 'test_user_id',
        name: 'Test User',
        email: 'test@example.com',
        cpr: '123456789',
        gender: 'Male',
        role: 'patient',
      );

      sensorProvider = SensorProvider();
      listenerCalled = false;

      sensorProvider.addListener(() {
        listenerCalled = true;
      });
    });

    tearDown(() {
      sensorProvider.dispose();
    });

    test('notifies listeners when ECG recording starts', () {
      sensorProvider.startCollection('ecg');
      expect(listenerCalled, true);
    });
  });
}
