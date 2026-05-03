import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/widgets/analytics_summary_card.dart';
import 'package:kairo/features/dashboard/widgets/empty_telemetry_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_database_analytics_card.dart';
import 'package:kairo/features/dashboard/widgets/telemetry_history_card.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AnalyticsScreen extends StatelessWidget {
  final MqttService _mqttService = MqttService.instance;

  AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: SafeArea(
        child: ValueListenableBuilder<MqttConnectionState>(
          valueListenable: _mqttService.connectionState,
          builder: (context, connectionState, child) {
            return ValueListenableBuilder<List<CubeTelemetryEntry>>(
              valueListenable: _mqttService.telemetryHistory,
              builder: (context, telemetryHistory, child) {
                return _AnalyticsContent(
                  connectionState: connectionState,
                  telemetryHistory: telemetryHistory,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final MqttConnectionState connectionState;
  final List<CubeTelemetryEntry> telemetryHistory;

  const _AnalyticsContent({
    required this.connectionState,
    required this.telemetryHistory,
  });

  @override
  Widget build(BuildContext context) {
    final latestEntry = telemetryHistory.isEmpty
        ? null
        : telemetryHistory.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cube Analytics',
            style: TextStyle(
              fontSize: context.sp(28),
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Realtime telemetry stream from your Kairo cube.',
            style: TextStyle(
              fontSize: context.sp(14),
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 28),
          AnalyticsSummaryCard(
            connectionState: connectionState,
            latestEntry: latestEntry,
          ),
          const SizedBox(height: 28),
          RealtimeDatabaseAnalyticsCard(),
          const SizedBox(height: 28),
          Text(
            'Realtime History',
            style: TextStyle(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (telemetryHistory.isEmpty)
            const EmptyTelemetryCard()
          else
            ...telemetryHistory.map((entry) {
              return TelemetryHistoryCard(entry: entry);
            }),
        ],
      ),
    );
  }
}
