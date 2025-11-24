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
  static const double ECG_SAMPLE_RATE = 250.0; // Hz
  static const double RECORDING_DURATION = 30.0;
  static final int EXPECTED_SAMPLES = (ECG_SAMPLE_RATE * RECORDING_DURATION).toInt();
  static const double MIN_SIGNAL_QUALITY = 0.7;
  
  // Latest sensor data
  SensorData _latest = SensorData(heartRate: 0, spo2: 0, timestamp: 0);
  SensorData get latest => _latest;

  // Real-time ECG display buffer (rolling window)
  final List<double> _realTimeEcgBuffer = [];
  final int _maxRealTimeBufferSize = 500; // ~2 seconds at 250Hz
  List<double> get realTimeEcgData => List.unmodifiable(_realTimeEcgBuffer);

  // Current mode from ESP32
  String _currentMode = "hr_spo2"; // "hr_spo2" or "ecg"
  String get currentMode => _currentMode;
  bool get isEcgMode => _currentMode == "ecg";

  // Latest readings
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
  
  // ECG Analysis
  final List<double> _rRIntervals = [];
  int _qrsCount = 0;
  double _signalQuality = 1.0;
  DateTime? _recordingStartTime;
  double _lastRPeakTime = 0.0;
  
  // Real-time ECG stats
  double _realtimeBPM = 0.0;
  String _realtimeRhythm = "Analyzing...";
  
  double get realtimeBPM => _realtimeBPM;
  String get realtimeRhythm => _realtimeRhythm;

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
    // Check mode
    final mode = dataJson['mode'] as String?;
    if (mode != null) {
      _currentMode = mode;
    }

    if (_currentMode == "hr_spo2") {
      // Process HR/SpO2 data
      final hr = dataJson['heartRate'];
      final sp = dataJson['spo2'];
      if (hr is num && sp is num) {
        _latest = SensorData.fromJson(dataJson);
        _addVitalSigns();
      }
    } else if (_currentMode == "ecg") {
      // Process ECG data
      final ecg = dataJson['ecg'];
      final status = dataJson['status'] as String?;
      final calculatedBPM = dataJson['calculatedBPM'];
      
      if (status != null) {
        _realtimeRhythm = status;
      }
      
      if (calculatedBPM is num) {
        _realtimeBPM = calculatedBPM.toDouble();
      }
      
      if (ecg != null) {
        _processEcgData(ecg);
      }
    }

    notifyListeners();
  }

  void _processEcgData(dynamic ecgData) {
    List<double> samples = [];
    
    if (ecgData is List) {
      // Convert raw ADC values (0-4095) to mV
      samples = ecgData.whereType<num>().map((rawValue) {
        // ESP32 12-bit ADC with 3.3V reference
        // Convert to voltage: (raw / 4095) * 3.3V
        // Center around 0: subtract 1.65V (midpoint)
        // Scale to ECG range: multiply by gain factor
        double voltage = (rawValue.toDouble() / 4095.0) * 3.3;
        double ecgMv = (voltage - 1.65) * 2.0; // Scale to ±3.3mV range
        return ecgMv.clamp(-3.0, 3.0);
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
    
    // Keep only the most recent samples
    while (_realTimeEcgBuffer.length > _maxRealTimeBufferSize) {
      _realTimeEcgBuffer.removeAt(0);
    }
  }

  void _analyzeEcgSamples(List<double> samples) {
    final threshold = 0.5; // mV threshold for R-peak detection
    final minRRInterval = 0.3; // Minimum 300ms between peaks (200 BPM max)
    
    for (int i = 2; i < samples.length - 2; i++) {
      final current = samples[i];
      final prev1 = samples[i - 1];
      final prev2 = samples[i - 2];
      final next1 = samples[i + 1];
      final next2 = samples[i + 2];
      
      // Detect R-peak: local maximum above threshold
      if (current > threshold &&
          current > prev1 && current > prev2 &&
          current > next1 && current > next2) {
        
        double currentTime = (_ecgRecordingBuffer.length + i) / ECG_SAMPLE_RATE;
        
        // Check minimum RR interval
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
    
    // Calculate signal quality metrics
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final variance = samples.map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / samples.length;
    final stdDev = math.sqrt(variance);
    
    // Check for artifacts
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
    
    // Use RR intervals for more accurate calculation
    if (_rRIntervals.isNotEmpty) {
      final avgRRInterval = _rRIntervals.reduce((a, b) => a + b) / _rRIntervals.length;
      return (60.0 / avgRRInterval).clamp(30.0, 200.0);
    }
    
    // Fallback to QRS count method
    final bpm = (_qrsCount / elapsedSeconds) * 60.0;
    return bpm.clamp(30.0, 200.0);
  }

  String _classifyRhythm() {
    final heartRate = _calculateHeartRateFromEcg();
    
    if (_signalQuality < MIN_SIGNAL_QUALITY) return 'Poor Signal Quality';
    if (heartRate < 60) return 'Bradycardia';
    if (heartRate > 100) return 'Tachycardia';
    
    // Check for irregular rhythm
    if (_rRIntervals.length > 3) {
      final mean = _rRIntervals.reduce((a, b) => a + b) / _rRIntervals.length;
      final variance = _rRIntervals.map((x) => math.pow(x - mean, 2))
          .reduce((a, b) => a + b) / _rRIntervals.length;
      final coefficient = math.sqrt(variance) / mean;
      
      if (coefficient > 0.15) return 'Irregular Rhythm';
    }
    
    return 'Normal Sinus Rhythm';
  }

  void onConnected() {
    print('MQTT Connected');
    client.subscribe(topic, MqttQos.atMostOnce);
  }
  
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
    
    print('ECG recording started');
    
    _qualityCheckTimer?.cancel();
    _qualityCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isEcgRecording) {
        timer.cancel();
        return;
      }
      print('Recording: ${_ecgRecordingBuffer.length}/${EXPECTED_SAMPLES} samples');
    });
    
    notifyListeners();
  }

  Future<void> _finishEcgRecording() async {
    if (!_isEcgRecording) return;

    _isEcgRecording = false;
    _qualityCheckTimer?.cancel();

    print('ECG recording finished: ${_ecgRecordingBuffer.length} samples');

    if (_ecgRecordingBuffer.length < EXPECTED_SAMPLES * 0.5) {
      print('Warning: ECG recording incomplete');
      notifyListeners();
      return;
    }

    final calculatedHR = _calculateHeartRateFromEcg();
    final rhythm = _classifyRhythm();

    print('ECG Analysis - HR: $calculatedHR, Rhythm: $rhythm, QRS: $_qrsCount');

    final reading = HealthReading(
      timestamp: DateTime.now(),
      value: calculatedHR,
      note: 'QRS count: $_qrsCount | Rhythm: $rhythm | Duration: ${RECORDING_DURATION}s',
      type: 'ecg',
      metadata: {
        'qrsCount': _qrsCount,
        'rhythm': rhythm,
        'signalQuality': _signalQuality,
        'rrIntervals': _rRIntervals.length,
        'recordingDuration': RECORDING_DURATION,
        'sampleRate': ECG_SAMPLE_RATE,
      },
    );

    _lastEcgReading = reading;
    await _saveToFirebase(reading);
    
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
      print('Saved ${reading.type} reading to Firebase');
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

  Stream<List<HealthReading>> ecgStream() {
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

  @override
  void dispose() {
    _collectionTimer?.cancel();
    _qualityCheckTimer?.cancel();
    client.disconnect();
    super.dispose();
  }
}