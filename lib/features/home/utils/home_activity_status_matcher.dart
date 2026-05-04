import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

StatusPreset? statusPresetForActivityEvent(
  List<StatusPreset> presets,
  RealtimeTelemetryHistoryItem? event,
) {
  if (event == null) {
    return null;
  }

  for (final preset in presets) {
    if (preset.id == event.entry.statusId) {
      return preset;
    }
  }

  for (final preset in presets) {
    if (preset.cubeFace == event.entry.cubeFace) {
      return preset;
    }
  }

  for (final preset in presets) {
    if (preset.cubeFace == event.entry.orientation) {
      return preset;
    }
  }

  return null;
}
