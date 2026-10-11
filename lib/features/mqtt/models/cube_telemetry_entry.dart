import 'dart:convert';

import 'package:kairo/features/mqtt/constants/cube_side_config.dart';

class CubeTelemetryEntry {
  final int? batteryPercent;
  final DateTime? cubeTimestamp;
  final String? cubeFace;
  final String? orientation;
  final String rawPayload;
  final DateTime receivedAt;
  final String? slackEmojiCode;
  final String? statusId;
  final String? statusLabel;
  final double? x;
  final double? y;
  final double? z;

  const CubeTelemetryEntry({
    required this.rawPayload,
    required this.receivedAt,
    this.batteryPercent,
    this.cubeFace,
    this.cubeTimestamp,
    this.orientation,
    this.slackEmojiCode,
    this.statusId,
    this.statusLabel,
    this.x,
    this.y,
    this.z,
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
        orientation: _asString(decoded['orientation']),
        batteryPercent: _asInt(decoded['batteryPercent'] ?? decoded['battery']),
        x: _asDouble(decoded['x']),
        y: _asDouble(decoded['y']),
        z: _asDouble(decoded['z']),
        cubeTimestamp: _asDateTime(decoded['timestamp']),
      );
    } catch (_) {
      return CubeTelemetryEntry(rawPayload: rawPayload, receivedAt: receivedAt);
    }
  }

  CubeTelemetryEntry copyWith({
    String? cubeFace,
    String? slackEmojiCode,
    String? statusId,
    String? statusLabel,
  }) {
    return CubeTelemetryEntry(
      batteryPercent: batteryPercent,
      cubeFace: cubeFace ?? this.cubeFace,
      cubeTimestamp: cubeTimestamp,
      orientation: orientation,
      rawPayload: rawPayload,
      receivedAt: receivedAt,
      slackEmojiCode: slackEmojiCode ?? this.slackEmojiCode,
      statusId: statusId ?? this.statusId,
      statusLabel: statusLabel ?? this.statusLabel,
      x: x,
      y: y,
      z: z,
    );
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

    return 'Not provided';
  }

  static String? _asString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
