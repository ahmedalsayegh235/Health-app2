import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorService {
  final String deviceIP; // e.g., 192.168.4.1 (ESP32 AP)
  final String userId;   // Firebase user ID
  Timer? _timer;

  SensorService({required this.deviceIP, required this.userId});

  void startReading() async {
    await http.get(Uri.parse('http://$deviceIP/start'));
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) => fetchReading());
  }

  void stopReading() async {
    await http.get(Uri.parse('http://$deviceIP/stop'));
    _timer?.cancel();
  }

  Future<void> fetchReading() async {
    try {
      final res = await http.get(Uri.parse('http://$deviceIP/reading'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        // Upload to Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('sensorData')
            .add({
          'heartRate': data['heartRate'],
          'spo2': data['spo2'],
          'ecg': data['ecg'],
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      print('Error fetching/uploading reading: $e');
    }
  }
}
