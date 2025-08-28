class HealthReading {
  final String id;
  final DateTime timestamp;
  final double value;
  final String note;
  final String type; // e.g., 'heart_rate', 'spo2', 'ecg', 'weight', 'bmi'
  final Map<String, dynamic>? metadata;

  HealthReading({
    String? id,
    required this.timestamp,
    required this.value,
    required this.note,
    this.type = 'general',
    this.metadata,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'note': note,
      'type': type,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory HealthReading.fromJson(Map<String, dynamic> json) {
    return HealthReading(
      id: json['id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String,
      type: json['type'] as String? ?? 'general',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Get ECG samples from metadata
  List<double> get ecgSamples {
    if (type == 'ecg' && metadata != null && metadata!['samples'] != null) {
      final samples = metadata!['samples'] as List;
      return samples.map<double>((e) => (e as num).toDouble()).toList();
    }
    return [];
  }

  /// Get ECG sampling rate (Hz)
  double get sampleRate {
    if (type == 'ecg' && metadata != null && metadata!['sampleRate'] != null) {
      return (metadata!['sampleRate'] as num).toDouble();
    }
    return 250.0; // Default medical ECG sample rate
  }

  /// Get recording duration in seconds
  double get duration {
    if (type == 'ecg' && metadata != null && metadata!['duration'] != null) {
      return (metadata!['duration'] as num).toDouble();
    }
    return ecgSamples.isNotEmpty ? ecgSamples.length / sampleRate : 0.0;
  }

  /// Get heart rate calculated from ECG (if available)
  double? get calculatedHeartRate {
    if (type == 'ecg' && metadata != null && metadata!['heartRate'] != null) {
      return (metadata!['heartRate'] as num).toDouble();
    }
    return null;
  }

  /// Get QRS complexes detected
  int get qrsCount {
    if (type == 'ecg' && metadata != null && metadata!['qrsCount'] != null) {
      return metadata!['qrsCount'] as int;
    }
    return 0;
  }

  /// Get signal quality indicator (0-1)
  double get signalQuality {
    if (type == 'ecg' && metadata != null && metadata!['signalQuality'] != null) {
      return (metadata!['signalQuality'] as num).toDouble();
    }
    return 1.0; // Default good quality
  }

  /// Get rhythm classification
  String get rhythmClassification {
    if (type == 'ecg' && metadata != null && metadata!['rhythm'] != null) {
      return metadata!['rhythm'] as String;
    }
    return 'Normal Sinus Rhythm';
  }

  /// Create ECG reading with samples
  factory HealthReading.createECGReading({
    required List<double> samples,
    required double sampleRate,
    required double duration,
    String? note,
    double? heartRate,
    int? qrsCount,
    double? signalQuality,
    String? rhythm,
  }) {
    // Calculate peak amplitude for value
    final peakAmplitude = samples.isNotEmpty 
        ? samples.reduce((curr, next) => curr.abs() > next.abs() ? curr : next)
        : 0.0;

    return HealthReading(
      timestamp: DateTime.now(),
      value: peakAmplitude,
      note: note ?? 'ECG Recording - ${duration.toInt()}s',
      type: 'ecg',
      metadata: {
        'samples': samples,
        'sampleRate': sampleRate,
        'duration': duration,
        'heartRate': heartRate,
        'qrsCount': qrsCount,
        'signalQuality': signalQuality ?? 1.0,
        'rhythm': rhythm ?? 'Normal Sinus Rhythm',
        'leadConfiguration': 'Lead I', // Default lead
        'filterSettings': {
          'highPass': 0.5,
          'lowPass': 40.0,
          'notch': 50.0, // 50Hz notch filter
        }
      },
    );
  }

  /// Copy with new values
  HealthReading copyWith({
    String? id,
    DateTime? timestamp,
    double? value,
    String? note,
    String? type,
    Map<String, dynamic>? metadata,
  }) {
    return HealthReading(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
      note: note ?? this.note,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthReading &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.value == value &&
        other.note == note &&
        other.type == type &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        value.hashCode ^
        note.hashCode ^
        type.hashCode ^
        metadata.hashCode;
  }

  @override
  String toString() {
    return 'HealthReading(id: $id, timestamp: $timestamp, value: $value, note: $note, type: $type, metadata: $metadata)';
  }
}