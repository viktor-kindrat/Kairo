import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

sealed class HomeActivityState {
  const HomeActivityState();
}

final class HomeActivityInitial extends HomeActivityState {
  const HomeActivityInitial();
}

final class HomeActivityLoading extends HomeActivityState {
  const HomeActivityLoading();
}

final class HomeActivityLoaded extends HomeActivityState {
  final List<RealtimeTelemetryHistoryItem> todayEvents;
  final RealtimeTelemetryHistoryItem? carryInEvent;
  final RealtimeTelemetryHistoryItem? latestEvent;
  final bool requiresSignIn;
  final String? errorMessage;
  final DateTime dayStart;

  const HomeActivityLoaded({
    required this.todayEvents,
    required this.dayStart,
    this.carryInEvent,
    this.latestEvent,
    this.requiresSignIn = false,
    this.errorMessage,
  });
}

final class HomeActivityError extends HomeActivityState {
  final String message;

  const HomeActivityError(this.message);
}
