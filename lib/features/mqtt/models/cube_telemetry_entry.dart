import 'dart:convert';

import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/mqtt/constants/cube_side_config.dart';

class CubeTelemetryEntry {
  final String rawPayload;
  final String? orientation;
  final String? statusLabel;
  final String? statusIconKey;
  final int? batteryPercent;
  final double? x;
  final double? y;
  final double? z;
  final DateTime? cubeTimestamp;
  final DateTime receivedAt;

  const CubeTelemetryEntry({
    required this.rawPayload,
    required this.receivedAt,
    this.orientation,
    this.statusLabel,
    this.statusIconKey,
    this.batteryPercent,
    this.x,
    this.y,
    this.z,
    this.cubeTimestamp,
  });

  factory CubeTelemetryEntry.fromPayload(String rawPayload) {
    final receivedAt = DateTime.now();

    try {
      final decoded = jsonDecode(rawPayload);

      if (decoded is! Map<String, dynamic>) {
        return CubeTelemetryEntry(
          rawPayload: rawPayload,
          receivedAt: receivedAt,
        );
      }

      return CubeTelemetryEntry(
        rawPayload: rawPayload,
        receivedAt: receivedAt,
        orientation: decoded['orientation'] as String?,
        statusLabel:
            decoded['statusLabel'] as String? ??
            decoded['status'] as String?,
        statusIconKey: decoded['statusIconKey'] as String?,
        batteryPercent: _asInt(
          decoded['batteryPercent'] ?? decoded['battery'],
        ),
        x: _asDouble(decoded['x']),
        y: _asDouble(decoded['y']),
        z: _asDouble(decoded['z']),
        cubeTimestamp: _asDateTime(decoded['timestamp']),
      );
    } catch (_) {
      return CubeTelemetryEntry(rawPayload: rawPayload, receivedAt: receivedAt);
    }
  }

  String get displayTimestamp {
    final date = cubeTimestamp ?? receivedAt;
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    final seconds = date.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get orientationLabel {
    return cubeSideLabelForValue(orientation);
  }

  String get resolvedStatusLabel {
    if (statusLabel != null && statusLabel!.trim().isNotEmpty) {
      return statusLabel!;
    }

    if (statusIconKey != null && statusIconKey!.trim().isNotEmpty) {
      return labelForStatusKey(statusIconKey!);
    }

    return 'Not provided';
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(Object? value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
