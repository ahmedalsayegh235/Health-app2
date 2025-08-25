import 'dart:async';
import 'dart:convert';
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

  SensorData _latest = SensorData(heartRate: 0, spo2: 0, timestamp: 0);
  SensorData get latest => _latest;

  HealthReading? _lastHeartRate;
  HealthReading? _lastSpo2;

  HealthReading? get lastHeartRate => _lastHeartRate;
  HealthReading? get lastSpo2 => _lastSpo2;
  String? get userId => UserModel.userData.id;
  


  final List<double> _hrBuffer = [];
  final List<int> _spo2Buffer = [];

  Timer? _collectionTimer;
  String? _currentCollectionType;

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
      final message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final data = SensorData.fromJson(jsonDecode(message));
        _latest = data;
        addSample();
        notifyListeners();
      } catch (e) {
        print('Error parsing MQTT data: $e');
      }
    });
  }

  void onConnected() => client.subscribe(topic, MqttQos.atMostOnce);
  void onDisconnected() => print('MQTT Disconnected');
  void onSubscribed(String t) => print('Subscribed to $t');

  void startCollection(String type) {
    if (type != 'heart_rate' && type != 'spo2') return;

    _currentCollectionType = type;
    _hrBuffer.clear();
    _spo2Buffer.clear();

    _collectionTimer?.cancel();
    _collectionTimer = Timer(const Duration(seconds: 30), _finishCollection);
  }

  void addSample() {
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
      final avg = (_spo2Buffer.reduce((a, b) => a + b) / _spo2Buffer.length).roundToDouble();
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
    if (userId == null) {
      print("No logged in user — cannot save reading");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('health_readings')
          .add(reading.toJson());
      print("Saved HealthReading: ${reading.toJson()}");
    } catch (e) {
      print("Error saving to Firebase: $e");
    }
  }

  Stream<List<HealthReading>> heartRateStream() {
    final userId = UserModel.userData.id;
    if (userId == null) {
      print("No userId found, returning empty stream");
      return Stream.value(<HealthReading>[]);
    }

    print("Creating heart rate stream for user: $userId");
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_readings')
        .where('type', isEqualTo: 'heart_rate')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Fetched ${snapshot.docs.length} heart rate readings");
          return snapshot.docs.map((doc) {
            try {
              return HealthReading.fromJson(doc.data());
            } catch (e) {
              print("Error parsing reading: $e");
              return null;
            }
          }).where((reading) => reading != null).cast<HealthReading>().toList();
        });
  }

  Stream<List<HealthReading>> spo2Stream() {
    final userId = UserModel.userData.id;
    if (userId == null) {
      print("No userId found, returning empty stream");
      return Stream.value(<HealthReading>[]);
    }

    print("Creating SpO2 stream for user: $userId");
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('health_readings')
        .where('type', isEqualTo: 'spo2')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print("Fetched ${snapshot.docs.length} SpO2 readings");
          return snapshot.docs.map((doc) {
            try {
              return HealthReading.fromJson(doc.data());
            } catch (e) {
              print("Error parsing reading: $e");
              return null;
            }
          }).where((reading) => reading != null).cast<HealthReading>().toList();
        });
  }
}