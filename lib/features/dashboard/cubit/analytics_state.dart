import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AnalyticsState {
  final List<RealtimeTelemetryHistoryItem> items;
  final bool hasMore;
  final bool isLoading;
  final bool isInitialLoadDone;
  final bool requiresSignIn;
  final String? errorMessage;
  final MqttConnectionState mqttConnectionState;
  final String? subscribedTopic;
  final MqttAnalyticsSummary? summary;

  const AnalyticsState({
    this.items = const [],
    this.hasMore = true,
    this.isLoading = false,
    this.isInitialLoadDone = false,
    this.requiresSignIn = false,
    this.errorMessage,
    this.mqttConnectionState = MqttConnectionState.disconnected,
    this.subscribedTopic,
    this.summary,
  });

  AnalyticsState copyWith({
    List<RealtimeTelemetryHistoryItem>? items,
    bool? hasMore,
    bool? isLoading,
    bool? isInitialLoadDone,
    bool? requiresSignIn,
    String? errorMessage,
    bool clearError = false,
    MqttConnectionState? mqttConnectionState,
    String? subscribedTopic,
    bool clearTopic = false,
    MqttAnalyticsSummary? summary,
  }) {
    return AnalyticsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isInitialLoadDone: isInitialLoadDone ?? this.isInitialLoadDone,
      requiresSignIn: requiresSignIn ?? this.requiresSignIn,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mqttConnectionState: mqttConnectionState ?? this.mqttConnectionState,
      subscribedTopic:
          clearTopic ? null : subscribedTopic ?? this.subscribedTopic,
      summary: summary ?? this.summary,
    );
  }
}
