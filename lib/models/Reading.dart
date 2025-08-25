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
