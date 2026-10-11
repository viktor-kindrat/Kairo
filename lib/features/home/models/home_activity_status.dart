import 'package:kairo/core/models/status_preset.dart';

class HomeActivityStatus {
  final Duration duration;
  final double progress;
  final StatusPreset preset;

  const HomeActivityStatus({
    required this.duration,
    required this.preset,
    required this.progress,
  });
}

class HomeActivitySnapshot {
  final StatusPreset? currentPreset;
  final Duration currentElapsed;
  final String? errorMessage;
  final bool hasActivityEvents;
  final bool isLoading;
  final int? latestBatteryPercent;
  final DateTime now;
  final bool requiresSignIn;
  final List<HomeActivityStatus> statuses;
  final Duration totalDuration;

  const HomeActivitySnapshot({
    required this.currentElapsed,
    required this.hasActivityEvents,
    required this.isLoading,
    required this.now,
    required this.requiresSignIn,
    required this.statuses,
    required this.totalDuration,
    this.currentPreset,
    this.errorMessage,
    this.latestBatteryPercent,
  });
}
