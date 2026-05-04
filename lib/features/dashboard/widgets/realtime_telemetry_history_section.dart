import 'package:flutter/material.dart';
import 'package:kairo/features/dashboard/widgets/empty_telemetry_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_analytics_message_card.dart';
import 'package:kairo/features/dashboard/widgets/telemetry_history_card.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

class RealtimeTelemetryHistorySection extends StatelessWidget {
  final List<RealtimeTelemetryHistoryItem> items;
  final bool isLoading;
  final bool isInitialLoadDone;
  final bool requiresSignIn;
  final String? errorMessage;
  final bool hasMore;
  final VoidCallback onLoadNextPage;

  const RealtimeTelemetryHistorySection({
    required this.items,
    required this.isLoading,
    required this.isInitialLoadDone,
    required this.requiresSignIn,
    required this.hasMore,
    required this.onLoadNextPage,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (requiresSignIn) {
      return const RealtimeAnalyticsMessageCard(
        message: 'Sign in to load saved MQTT history.',
      );
    }

    if (items.isEmpty && isLoading) {
      return const RealtimeAnalyticsMessageCard(
        leading: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        message: 'Loading saved MQTT history...',
      );
    }

    if (items.isEmpty && errorMessage != null) {
      return RealtimeAnalyticsMessageCard(message: errorMessage!);
    }

    if (items.isEmpty && isInitialLoadDone) {
      return const EmptyTelemetryCard();
    }

    return Column(
      children: [
        ...items.map((item) => TelemetryHistoryCard(entry: item.entry)),
        _HistoryPaginationFooter(
          isLoading: isLoading,
          errorMessage: errorMessage,
          onLoadNextPage: onLoadNextPage,
        ),
      ],
    );
  }
}

class _HistoryPaginationFooter extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLoadNextPage;

  const _HistoryPaginationFooter({
    required this.isLoading,
    required this.onLoadNextPage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (errorMessage != null) {
      return TextButton(
        onPressed: onLoadNextPage,
        child: const Text('Retry loading history'),
      );
    }

    return const SizedBox.shrink();
  }
}
