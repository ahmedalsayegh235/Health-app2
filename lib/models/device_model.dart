import 'package:health/helpers/Device_Tab_helpers.dart';

class DeviceModel {
  final String id;
  final String name;
  final DeviceType type;
  ConnectionStatus status;
  final int batteryLevel;
  DateTime lastSync;
  final List<String> features;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.batteryLevel,
    required this.lastSync,
    required this.features,
  });
}