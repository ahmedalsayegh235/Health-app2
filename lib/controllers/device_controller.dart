import 'package:flutter/material.dart';
import 'package:health/helpers/Device_Tab_helpers.dart';
import 'package:health/models/device_model.dart';
import 'package:health/helpers/app_theme.dart';

class DeviceController extends ChangeNotifier {
  final List<DeviceModel> _devices = [];

  List<DeviceModel> get devices => _devices;

  void initDevices() {
    _devices.clear();
    _devices.addAll([
      DeviceModel(
        id: '1',
        name: 'Smart Watch Pro',
        type: DeviceType.smartwatch,
        status: ConnectionStatus.connected,
        batteryLevel: 85,
        lastSync: DateTime.now().subtract(const Duration(minutes: 2)),
        features: ['Heart Rate', 'Steps', 'Sleep'],
      ),
      DeviceModel(
        id: '2',
        name: 'Blood Pressure Monitor',
        type: DeviceType.bloodPressure,
        status: ConnectionStatus.connected,
        batteryLevel: 92,
        lastSync: DateTime.now().subtract(const Duration(hours: 1)),
        features: ['Blood Pressure', 'Heart Rate'],
      ),
      DeviceModel(
        id: '3',
        name: 'Smart Scale Pro',
        type: DeviceType.scale,
        status: ConnectionStatus.disconnected,
        batteryLevel: 45,
        lastSync: DateTime.now().subtract(const Duration(days: 3)),
        features: ['Weight', 'BMI', 'Body Fat'],
      ),
      DeviceModel(
        id: '4',
        name: 'Pulse Oximeter',
        type: DeviceType.pulseOximeter,
        status: ConnectionStatus.connecting,
        batteryLevel: 78,
        lastSync: DateTime.now().subtract(const Duration(hours: 6)),
        features: ['SpO2', 'Heart Rate'],
      ),
      DeviceModel(
        id: '5',
        name: 'ECG Monitor',
        type: DeviceType.ecg,
        status: ConnectionStatus.disconnected,
        batteryLevel: 23,
        lastSync: DateTime.now().subtract(const Duration(days: 7)),
        features: ['ECG', 'Heart Rate'],
      ),
    ]);
    notifyListeners();
  }

  void connectDevice(BuildContext context, DeviceModel device) {
    device.status = ConnectionStatus.connecting;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      device.status = ConnectionStatus.connected;
      device.lastSync = DateTime.now();
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${device.name} connected successfully!'),
          backgroundColor: AppTheme.lightgreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  void disconnectDevice(BuildContext context, DeviceModel device) {
    device.status = ConnectionStatus.disconnected;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.name} disconnected'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void syncDevice(BuildContext context, DeviceModel device) {
    if (device.status != ConnectionStatus.connected) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing ${device.name}...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      device.lastSync = DateTime.now();
      notifyListeners();
    });
  }

  void syncAllDevices(BuildContext context) {
    for (var device in _devices) {
      if (device.status == ConnectionStatus.connected) {
        syncDevice(context, device);
      }
    }
  }

  void scanDevices(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Scanning for devices...'),
        backgroundColor: AppTheme.lightgreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  int get connectedCount =>
      _devices.where((d) => d.status == ConnectionStatus.connected).length;

  int get totalCount => _devices.length;
}
