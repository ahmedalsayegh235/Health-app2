class SensorData {
  final double heartRate;
  final int spo2;
  final int timestamp;

  SensorData({
    required this.heartRate,
    required this.spo2,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      heartRate: (json['heartRate'] as num).toDouble(),   // force double
      spo2: (json['spo2'] as num).toInt(),               // force int
      timestamp: (json['timestamp'] as num).toInt(),     // force int
    );
  }

  Map<String, dynamic> toJson() => {
        'heartRate': heartRate,
        'spo2': spo2,
        'timestamp': timestamp,
      };
}
