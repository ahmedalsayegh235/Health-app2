import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health/models/Reading.dart';
import 'package:health/models/sensor_model.dart';
import 'package:health/models/user_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SensorProvider with ChangeNotifier {
  late MqttServerClient client;
  final String broker = 'broker.hivemq.com';
  final int port = 1883;
  final String topic = 'esp32/health';

  // ECG Configuration Constants
  static const double ECG_SAMPLE_RATE = 250.0; // Hz - Medical standard
  static const double RECORDING_DURATION = 30.0; // Full 30 seconds for accurate BPM
  static final int EXPECTED_SAMPLES = (ECG_SAMPLE_RATE * RECORDING_DURATION).toInt();
  static const double MIN_SIGNAL_QUALITY = 0.7;
  
  // Latest sensor data
  SensorData _latest = SensorData(heartRate: 0, spo2: 0, timestamp: 0);
  SensorData get latest => _latest;

  // Real-time ECG for display (circular buffer)
  final List<double> _realTimeEcgBuffer = [];
  final int _maxRealTimeBufferSize = 500; // ~2 seconds at 250Hz for better performance
  List<double> get realTimeEcgData => List.unmodifiable(_realTimeEcgBuffer);

  // Latest individual readings
  HealthReading? _lastHeartRate;
  HealthReading? _lastSpo2;
  HealthReading? _lastEcgReading;

  HealthReading? get lastHeartRate => _lastHeartRate;
  HealthReading? get lastSpo2 => _lastSpo2;
  HealthReading? get lastEcgReading => _lastEcgReading;
  String? get userId => UserModel.userData.id;

  // Collection buffers
  final List<double> _hrBuffer = [];
  final List<int> _spo2Buffer = [];
  final List<double> _ecgRecordingBuffer = [];
  
  // ECG Analysis variables
  final List<double> _rRIntervals = [];
  int _qrsCount = 0;
  double _signalQuality = 1.0;
  DateTime? _recordingStartTime;
  double _lastRPeakTime = 0.0;

  Timer? _collectionTimer;
  Timer? _qualityCheckTimer;
  String? _currentCollectionType;
  bool _isEcgRecording = false;

  bool get isEcgRecording => _isEcgRecording;
  double get ecgRecordingProgress => _isEcgRecording 
      ? (_ecgRecordingBuffer.length / EXPECTED_SAMPLES).clamp(0.0, 1.0)
      : 0.0;

  SensorProvider() {
    Future.microtask(() => _connect());
    _generateRealtimeEcgSimulation();
  }

  Future<void> _connect() async {
    final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient(broker, clientId)
      ..port = port
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..logging(on: false)
      ..onConnected = onConnected
      ..onDisconnected = onDisconnected
      ..onSubscribed = onSubscribed;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT connect error: $e');
      client.disconnect();
      return;
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final dataJson = jsonDecode(message);
        if (dataJson is Map<String, dynamic>) {
          _processSensorData(dataJson);
        }
      } catch (e) {
        print('Error parsing MQTT data: $e');
      }
    });
  }

  void _processSensorData(Map<String, dynamic> dataJson) {
    // Update latest sensor values
    final hr = dataJson['heartRate'];
    final sp = dataJson['spo2'];
    if (hr is num && sp is num) {
      _latest = SensorData.fromJson(dataJson);
    }

    _addVitalSigns();

    // Process ECG data - convert raw values to mV
    final ecg = dataJson['ecg'];
    if (ecg != null) {
      _processEcgData(ecg);
    }

    notifyListeners();
  }

  void _processEcgData(dynamic ecgData) {
    List<double> samples = [];
    
    if (ecgData is List) {
      // Convert raw ADC values to mV (assuming 12-bit ADC, 3.3V reference, gain)
      samples = ecgData.whereType<num>().map((rawValue) {
        // Convert raw ADC to voltage, then to mV with appropriate scaling
        // Typical ECG amplitude: -2mV to +2mV
        double voltage = (rawValue.toDouble() / 4095.0) * 3.3; // Convert to voltage
        double ecgMv = (voltage - 1.65) * 2.0; // Center around 0, scale to ±3.3mV range
        return ecgMv.clamp(-3.0, 3.0); // Clamp to realistic ECG range
      }).toList();
    } else if (ecgData is num) {
      double voltage = (ecgData.toDouble() / 4095.0) * 3.3;
      double ecgMv = (voltage - 1.65) * 2.0;
      samples = [ecgMv.clamp(-3.0, 3.0)];
    }

    if (samples.isNotEmpty) {
      _addToRealTimeBuffer(samples);
      
      if (_isEcgRecording) {
        _ecgRecordingBuffer.addAll(samples);
        _analyzeEcgSamples(samples);
        
        if (_ecgRecordingBuffer.length >= EXPECTED_SAMPLES) {
          _finishEcgRecording();
        }
      }
    }
  }

  void _addToRealTimeBuffer(List<double> samples) {
    _realTimeEcgBuffer.addAll(samples);
    
    while (_realTimeEcgBuffer.length > _maxRealTimeBufferSize) {
      _realTimeEcgBuffer.removeAt(0);
    }
  }

  void _analyzeEcgSamples(List<double> samples) {
    // Improved R-peak detection with better threshold and timing
    final threshold = 0.5; // mV threshold for R-peak
    final minRRInterval = 0.3; // Minimum 300ms between R-peaks (200 BPM max)
    
    for (int i = 2; i < samples.length - 2; i++) {
      final current = samples[i];
      final prev1 = samples[i - 1];
      final prev2 = samples[i - 2];
      final next1 = samples[i + 1];
      final next2 = samples[i + 2];
      
      // Check if current sample is a local maximum above threshold
      if (current > threshold &&
          current > prev1 && current > prev2 &&
          current > next1 && current > next2) {
        
        double currentTime = (_ecgRecordingBuffer.length + i) / ECG_SAMPLE_RATE;
        
        // Check minimum RR interval to avoid double counting
        if (currentTime - _lastRPeakTime > minRRInterval) {
          _qrsCount++;
          
          // Calculate RR interval
          if (_lastRPeakTime > 0) {
            double rrInterval = currentTime - _lastRPeakTime;
            _rRIntervals.add(rrInterval);
          }
          
          _lastRPeakTime = currentTime;
        }
      }
    }
    
    _updateSignalQuality(samples);
  }

  void _updateSignalQuality(List<double> samples) {
    if (samples.isEmpty) return;
    
    // Calculate signal quality based on multiple factors
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final variance = samples.map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / samples.length;
    final stdDev = math.sqrt(variance);
    
    // Check for signal artifacts (too high amplitude or flat line)
    final maxAbs = samples.map((x) => x.abs()).reduce(math.max);
    final isFlat = stdDev < 0.01;
    final hasArtifacts = maxAbs > 2.5;
    
    double qualityScore = 1.0;
    if (isFlat) qualityScore *= 0.3;
    if (hasArtifacts) qualityScore *= 0.5;
    if (stdDev < 0.1) qualityScore *= 0.7;
    
    // Smooth the quality indicator
    _signalQuality = (_signalQuality * 0.8) + (qualityScore * 0.2);
  }

  double _calculateHeartRateFromEcg() {
    if (_qrsCount < 2 || _recordingStartTime == null) return 0.0;
    
    final elapsedSeconds = DateTime.now().difference(_recordingStartTime!).inSeconds.toDouble();
    if (elapsedSeconds <= 0) return 0.0;
    
    // Use RR intervals for more accurate calculation if available
    if (_rRIntervals.isNotEmpty) {
      final avgRRInterval = _rRIntervals.reduce((a, b) => a + b) / _rRIntervals.length;
      return (60.0 / avgRRInterval).clamp(30.0, 200.0);
    }
    
    // Fallback to QRS count method - more accurate calculation
    final bpm = (_qrsCount / elapsedSeconds) * 60.0;
    return bpm.clamp(30.0, 200.0);
  }

  String _classifyRhythm() {
    final heartRate = _calculateHeartRateFromEcg();
    
    if (_signalQuality < MIN_SIGNAL_QUALITY) return 'Poor Signal Quality';
    if (heartRate < 60) return 'Bradycardia';
    if (heartRate > 100) return 'Tachycardia';
    
    // Check for irregular rhythm based on RR interval variability
    if (_rRIntervals.length > 3) {
      final mean = _rRIntervals.reduce((a, b) => a + b) / _rRIntervals.length;
      final variance = _rRIntervals.map((x) => math.pow(x - mean, 2))
          .reduce((a, b) => a + b) / _rRIntervals.length;
      final coefficient = math.sqrt(variance) / mean;
      
      if (coefficient > 0.15) return 'Irregular Rhythm';
    }
    
    return 'Normal Sinus Rhythm';
  }

  // Improved ECG simulation with more realistic waveform
  void _generateRealtimeEcgSimulation() {
    Timer.periodic(const Duration(milliseconds: 4), (timer) {
      if (!_isEcgRecording) {
        final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final ecgValue = _generateEcgSample(t);
        _addToRealTimeBuffer([ecgValue]);
        notifyListeners();
      }
    });
  }

  double _generateEcgSample(double time) {
    final heartRate = 75.0; // BPM
    final period = 60.0 / heartRate;
    final phase = (time % period) / period;
    
    double ecg = 0.0;
    
    // More realistic ECG waveform generation
    if (phase < 0.15) {
      // P wave
      final pPhase = phase / 0.15 * math.pi;
      ecg += 0.15 * math.sin(pPhase);
    } else if (phase >= 0.15 && phase < 0.25) {
      // PR interval (baseline)
      ecg += 0.0;
    } else if (phase >= 0.25 && phase < 0.35) {
      // QRS complex
      final qrsPhase = (phase - 0.25) / 0.1;
      if (qrsPhase < 0.3) {
        // Q wave
        ecg += -0.2 * math.sin(qrsPhase * math.pi / 0.3);
      } else if (qrsPhase < 0.7) {
        // R wave
        final rPhase = (qrsPhase - 0.3) / 0.4;
        ecg += 1.2 * math.sin(rPhase * math.pi);
      } else {
        // S wave
        final sPhase = (qrsPhase - 0.7) / 0.3;
        ecg += -0.3 * math.sin(sPhase * math.pi);
      }
    } else if (phase >= 0.35 && phase < 0.45) {
      // ST segment (baseline)
      ecg += 0.0;
    } else if (phase >= 0.45 && phase < 0.7) {
      // T wave
      final tPhase = (phase - 0.45) / 0.25 * math.pi;
      ecg += 0.3 * math.sin(tPhase);
    }
    
    // Add minimal noise
    ecg += (math.Random().nextDouble() - 0.5) * 0.02;
    
    return ecg;
  }

  void onConnected() => client.subscribe(topic, MqttQos.atMostOnce);
  void onDisconnected() => print('MQTT Disconnected');
  void onSubscribed(String t) => print('Subscribed to $t');

  void startCollection(String type) {
    if (type != 'heart_rate' && type != 'spo2' && type != 'ecg') return;

    _currentCollectionType = type;

    if (type == 'ecg') {
      _startEcgRecording();
    } else {
      _hrBuffer.clear();
      _spo2Buffer.clear();
      _collectionTimer?.cancel();
      _collectionTimer = Timer(const Duration(seconds: 30), _finishCollection);
    }
  }

  void _startEcgRecording() {
    _isEcgRecording = true;
    _ecgRecordingBuffer.clear();
    _qrsCount = 0;
    _signalQuality = 1.0;
    _rRIntervals.clear();
    _lastRPeakTime = 0.0;
    _recordingStartTime = DateTime.now();
    
    _qualityCheckTimer?.cancel();
    _qualityCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isEcgRecording) {
        timer.cancel();
        return;
      }
    });
    
    notifyListeners();
  }

  Future<void> _finishEcgRecording() async {
    if (!_isEcgRecording) return;

    _isEcgRecording = false;
    _qualityCheckTimer?.cancel();

    if (_ecgRecordingBuffer.length < EXPECTED_SAMPLES * 0.5) {
      print('Warning: ECG recording incomplete');
      notifyListeners();
      return;
    }

    final calculatedHR = _calculateHeartRateFromEcg();
    final rhythm = _classifyRhythm();

    // Create ECG reading with BPM as the main value and store rhythm in metadata
    final reading = HealthReading(
      timestamp: DateTime.now(),
      value: calculatedHR, // BPM as the main value
      note: 'QRS count: $_qrsCount | Rhythm: $rhythm | Duration: ${RECORDING_DURATION}s',
      type: 'ecg',
      metadata: {
        'qrsCount': _qrsCount,
        'rhythm': rhythm,
        'signalQuality': _signalQuality,
        'rrIntervals': _rRIntervals.length,
        'recordingDuration': RECORDING_DURATION,
      },
    );

    _lastEcgReading = reading;
    _saveToFirebase(reading);
    
    _currentCollectionType = null;
    notifyListeners();
  }

  void stopEcgRecording() {
    if (_isEcgRecording) {
      _finishEcgRecording();
    }
  }

  void _addVitalSigns() {
    if (_currentCollectionType == null) return;

    if (_currentCollectionType == 'heart_rate' && _latest.heartRate > 0) {
      _hrBuffer.add(_latest.heartRate);
    } else if (_currentCollectionType == 'spo2' && _latest.spo2 > 0) {
      _spo2Buffer.add(_latest.spo2);
    }
  }

  void _finishCollection() {
    if (_currentCollectionType == null) return;

    if (_currentCollectionType == 'heart_rate' && _hrBuffer.isNotEmpty) {
      final avg = _hrBuffer.reduce((a, b) => a + b) / _hrBuffer.length;
      final reading = HealthReading(
        timestamp: DateTime.now(),
        value: avg,
        note: 'Avg of ${_hrBuffer.length} samples',
        type: 'heart_rate',
      );
      _lastHeartRate = reading;
      _saveToFirebase(reading);
    } else if (_currentCollectionType == 'spo2' && _spo2Buffer.isNotEmpty) {
      final avg = (_spo2Buffer.reduce((a, b) => a + b) / _spo2Buffer.length)
          .roundToDouble();
      final reading = HealthReading(
        timestamp: DateTime.now(),
        value: avg,
        note: 'Avg of ${_spo2Buffer.length} samples',
        type: 'spo2',
      );
      _lastSpo2 = reading;
      _saveToFirebase(reading);
    }

    _currentCollectionType = null;
    notifyListeners();
  }

  Future<void> _saveToFirebase(HealthReading reading) async {
    final userId = UserModel.userData.id;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('health_readings')
          .add(reading.toJson());
    } catch (e) {
      print("Error saving to Firebase: $e");
    }
  }

  Stream<List<HealthReading>> heartRateStream() {
    final userId = UserModel.userData.id;
    if (userId == null) return Stream.value(<HealthReading>[]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_readings')
        .where('type', isEqualTo: 'heart_rate')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return HealthReading.fromJson(doc.data());
              } catch (e) {
                print("Error parsing reading: $e");
                return null;
              }
            }).where((reading) => reading != null).cast<HealthReading>().toList());
  }

  Stream<List<HealthReading>> spo2Stream() {
    final userId = UserModel.userData.id;
    if (userId == null) return Stream.value(<HealthReading>[]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_readings')
        .where('type', isEqualTo: 'spo2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return HealthReading.fromJson(doc.data());
              } catch (e) {
                print("Error parsing reading: $e");
                return null;
              }
            }).where((reading) => reading != null).cast<HealthReading>().toList());
  }

  Stream<List<HealthReading>> ecgStream(){
    final userId = UserModel.userData.id;
    if (userId == null) return Stream.value(<HealthReading>[]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_readings')
        .where('type', isEqualTo: 'ecg')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return HealthReading.fromJson(doc.data());
              } catch (e) {
                print("Error parsing reading: $e");
                return null;
              }
            }).where((reading) => reading != null).cast<HealthReading>().toList());

  }
}