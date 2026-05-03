import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

class RealtimeTelemetryHistoryPage {
  final bool hasMore;
  final List<RealtimeTelemetryHistoryItem> items;

  const RealtimeTelemetryHistoryPage({
    required this.hasMore,
    required this.items,
  });
}
