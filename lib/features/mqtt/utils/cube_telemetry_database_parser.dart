import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

CubeTelemetryEntry cubeTelemetryEntryFromDatabaseValue(Object? value) {
  final map = _databaseMap(value);

  return CubeTelemetryEntry(
    rawPayload: _asString(map['rawPayload']) ?? '',
    receivedAt: _asDateTime(map['receivedAt']) ?? DateTime.now(),
    orientation: _asString(map['orientation']),
    statusId: _asString(map['statusId']),
    statusLabel: _asString(map['statusLabel']),
    slackEmojiCode: _asString(map['slackEmojiCode']),
    cubeFace: _asString(map['cubeFace']),
    batteryPercent: _asInt(map['batteryPercent']),
    x: _asDouble(map['x']),
    y: _asDouble(map['y']),
    z: _asDouble(map['z']),
    cubeTimestamp: _asDateTime(map['cubeTimestamp']),
  );
}

Map<String, Object?> _databaseMap(Object? value) {
  if (value is! Map) {
    return const {};
  }

  return value.map((key, value) => MapEntry(key.toString(), value));
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }

  final text = value.toString();
  return text.trim().isEmpty ? null : text;
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.round();
  }

  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(Object? value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '');
}

DateTime? _asDateTime(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '');
}
