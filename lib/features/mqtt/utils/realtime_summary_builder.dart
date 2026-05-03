import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';

Map<String, Object?> buildUpdatedMqttSummary({
  required Object? currentData,
  required CubeTelemetryEntry entry,
  required String eventId,
}) {
  final summary = MqttAnalyticsSummary.fromSnapshotValue(currentData);
  final receivedAt = entry.receivedAt.toIso8601String();
  final battery = entry.batteryPercent;
  final nextBatterySamples = summary.batterySamples + (battery == null ? 0 : 1);
  final nextBatteryTotal = summary.batteryTotal + (battery ?? 0);
  final nextAverageBattery = nextBatterySamples == 0
      ? 0
      : nextBatteryTotal / nextBatterySamples;

  return {
    'totalEvents': summary.totalEvents + 1,
    'firstSeenAt': summary.firstSeenAt?.toIso8601String() ?? receivedAt,
    'lastSeenAt': receivedAt,
    'latestEventId': eventId,
    'orientationCounts': _incrementedCounts(
      summary.orientationCounts,
      entry.orientationLabel,
    ),
    'statusCounts': _incrementedCounts(
      summary.statusCounts,
      entry.resolvedStatusLabel,
    ),
    'batterySamples': nextBatterySamples,
    'batteryTotal': nextBatteryTotal,
    'batteryMin': _minBattery(summary.batteryMin, battery),
    'batteryMax': _maxBattery(summary.batteryMax, battery),
    'averageBattery': nextAverageBattery,
  };
}

Map<String, int> _incrementedCounts(Map<String, int> counts, String key) {
  final updatedCounts = {...counts};
  updatedCounts[key] = (updatedCounts[key] ?? 0) + 1;
  return updatedCounts;
}

int? _maxBattery(int? currentValue, int? nextValue) {
  if (nextValue == null) {
    return currentValue;
  }

  if (currentValue == null || nextValue > currentValue) {
    return nextValue;
  }

  return currentValue;
}

int? _minBattery(int? currentValue, int? nextValue) {
  if (nextValue == null) {
    return currentValue;
  }

  if (currentValue == null || nextValue < currentValue) {
    return nextValue;
  }

  return currentValue;
}
