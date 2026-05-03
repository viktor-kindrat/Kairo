import 'package:flutter/material.dart';
import 'package:kairo/features/dashboard/controllers/realtime_history_controller.dart';
import 'package:kairo/features/dashboard/widgets/empty_telemetry_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_analytics_message_card.dart';
import 'package:kairo/features/dashboard/widgets/telemetry_history_card.dart';

class RealtimeTelemetryHistorySection extends StatelessWidget {
  final RealtimeHistoryController controller;

  const RealtimeTelemetryHistorySection({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.requiresSignIn) {
          return const RealtimeAnalyticsMessageCard(
            message: 'Sign in to load saved MQTT history.',
          );
        }

        if (controller.items.isEmpty && controller.isLoading) {
          return const RealtimeAnalyticsMessageCard(
            leading: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            message: 'Loading saved MQTT history...',
          );
        }

        if (controller.items.isEmpty && controller.errorMessage != null) {
          return RealtimeAnalyticsMessageCard(
            message: controller.errorMessage!,
          );
        }

        if (controller.items.isEmpty && controller.isInitialLoadDone) {
          return const EmptyTelemetryCard();
        }

        return Column(
          children: [
            ...controller.items.map((item) {
              return TelemetryHistoryCard(entry: item.entry);
            }),
            _HistoryPaginationFooter(controller: controller),
          ],
        );
      },
    );
  }
}

class _HistoryPaginationFooter extends StatelessWidget {
  final RealtimeHistoryController controller;

  const _HistoryPaginationFooter({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (controller.errorMessage != null) {
      return TextButton(
        onPressed: controller.loadNextPage,
        child: const Text('Retry loading history'),
      );
    }

    return const SizedBox.shrink();
  }
}
