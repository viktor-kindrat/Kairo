import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

extension CubeTelemetryRealtimeMapper on CubeTelemetryEntry {
  Map<String, Object?> toRealtimeDatabaseMap() {
    final map = <String, Object?>{
      'rawPayload': rawPayload,
      'orientation': orientation,
      'orientationLabel': orientationLabel,
      'statusLabel': statusLabel,
      'statusIconKey': statusIconKey,
      'resolvedStatusLabel': resolvedStatusLabel,
      'batteryPercent': batteryPercent,
      'x': x,
      'y': y,
      'z': z,
      'cubeTimestamp': cubeTimestamp?.toIso8601String(),
      'receivedAt': receivedAt.toIso8601String(),
    };

    map.removeWhere((key, value) => value == null);
    return map;
  }
}
