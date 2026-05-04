import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

class RealtimeTelemetryHistoryItem {
  final CubeTelemetryEntry entry;
  final String id;

  const RealtimeTelemetryHistoryItem({required this.entry, required this.id});
}
