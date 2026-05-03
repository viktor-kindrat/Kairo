import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/models/home_activity_status.dart';
import 'package:kairo/features/home/utils/home_activity_status_matcher.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

class HomeActivityCalculator {
  const HomeActivityCalculator();

  HomeActivitySnapshot calculate({
    required DateTime dayStart,
    required List<RealtimeTelemetryHistoryItem> events,
    required bool isLoading,
    required DateTime now,
    required List<StatusPreset> presets,
    required bool requiresSignIn,
    RealtimeTelemetryHistoryItem? carryInEvent,
    String? errorMessage,
    RealtimeTelemetryHistoryItem? latestEvent,
  }) {
    final sortedPresets = _sortedPresets(presets);
    final durations = {
      for (final preset in sortedPresets) preset.id: Duration.zero,
    };
    final sortedEvents = _sortedEvents(events);
    var activeEvent = carryInEvent;
    if (activeEvent == null &&
        latestEvent?.entry.receivedAt.toLocal().isBefore(dayStart) == true) {
      activeEvent = latestEvent;
    }
    var cursor = dayStart;

    if (activeEvent == null && sortedEvents.isEmpty && latestEvent != null) {
      activeEvent = latestEvent;
      cursor = _clampedEventTime(latestEvent, dayStart, now);
    }

    for (final event in sortedEvents) {
      final eventTime = _clampedEventTime(event, dayStart, now);
      final activePreset = statusPresetForActivityEvent(
        sortedPresets,
        activeEvent,
      );
      final nextPreset = statusPresetForActivityEvent(sortedPresets, event);

      if (activeEvent != null && eventTime.isAfter(cursor)) {
        _addDuration(durations, sortedPresets, activeEvent, eventTime, cursor);
      }

      if (activeEvent == null || activePreset?.id != nextPreset?.id) {
        activeEvent = event;
      }

      cursor = eventTime;
    }

    if (activeEvent != null && now.isAfter(cursor)) {
      _addDuration(durations, sortedPresets, activeEvent, now, cursor);
    }

    final totalDuration = durations.values.fold(
      Duration.zero,
      (total, duration) => total + duration,
    );
    final currentEvent = activeEvent ?? latestEvent;
    final currentPreset = statusPresetForActivityEvent(
      sortedPresets,
      currentEvent,
    );
    final latestSavedEvent = sortedEvents.isNotEmpty
        ? sortedEvents.last
        : latestEvent ?? carryInEvent;
    final currentElapsed = currentEvent == null
        ? Duration.zero
        : now.difference(currentEvent.entry.receivedAt.toLocal());

    return HomeActivitySnapshot(
      currentElapsed: currentElapsed,
      currentPreset: currentPreset,
      errorMessage: errorMessage,
      hasActivityEvents:
          carryInEvent != null ||
          latestEvent != null ||
          sortedEvents.isNotEmpty,
      isLoading: isLoading,
      latestBatteryPercent: latestSavedEvent?.entry.batteryPercent,
      now: now,
      requiresSignIn: requiresSignIn,
      statuses: sortedPresets
          .map((preset) {
            final duration = durations[preset.id] ?? Duration.zero;

            return HomeActivityStatus(
              duration: duration,
              preset: preset,
              progress: totalDuration == Duration.zero
                  ? 0
                  : duration.inMilliseconds / totalDuration.inMilliseconds,
            );
          })
          .toList(growable: false),
      totalDuration: totalDuration,
    );
  }

  void _addDuration(
    Map<String, Duration> durations,
    List<StatusPreset> presets,
    RealtimeTelemetryHistoryItem event,
    DateTime end,
    DateTime start,
  ) {
    final preset = statusPresetForActivityEvent(presets, event);

    if (preset == null) {
      return;
    }

    durations[preset.id] =
        (durations[preset.id] ?? Duration.zero) + end.difference(start);
  }

  DateTime _clampedEventTime(
    RealtimeTelemetryHistoryItem event,
    DateTime dayStart,
    DateTime now,
  ) {
    final eventTime = event.entry.receivedAt.toLocal();

    if (eventTime.isBefore(dayStart)) {
      return dayStart;
    }

    if (eventTime.isAfter(now)) {
      return now;
    }

    return eventTime;
  }

  List<RealtimeTelemetryHistoryItem> _sortedEvents(
    List<RealtimeTelemetryHistoryItem> events,
  ) {
    return [...events]..sort((a, b) {
      return a.entry.receivedAt.compareTo(b.entry.receivedAt);
    });
  }

  List<StatusPreset> _sortedPresets(List<StatusPreset> presets) {
    return [...presets]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
