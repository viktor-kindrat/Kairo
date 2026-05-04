import 'package:flutter/material.dart';
import 'package:kairo/features/dashboard/widgets/mqtt_analytics_summary_content.dart';
import 'package:kairo/features/dashboard/widgets/realtime_analytics_message_card.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';

class RealtimeDatabaseAnalyticsCard extends StatelessWidget {
  final MqttAnalyticsSummary? summary;
  final bool isLoading;
  final bool requiresSignIn;

  const RealtimeDatabaseAnalyticsCard({
    this.summary,
    this.isLoading = false,
    this.requiresSignIn = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (requiresSignIn) {
      return const RealtimeAnalyticsMessageCard(
        message: 'Sign in to sync MQTT analytics.',
      );
    }

    if (isLoading && summary == null) {
      return const RealtimeAnalyticsMessageCard(
        leading: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        message: 'Loading saved MQTT analytics...',
      );
    }

    final data = summary;

    if (data == null || !data.hasData) {
      return const RealtimeAnalyticsMessageCard(
        message: 'No saved MQTT analytics yet.',
      );
    }

    return MqttAnalyticsSummaryContent(summary: data);
  }
}
