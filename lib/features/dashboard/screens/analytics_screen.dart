import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/controllers/realtime_history_controller.dart';
import 'package:kairo/features/dashboard/widgets/analytics_summary_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_database_analytics_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_telemetry_history_section.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:kairo/features/profile/widgets/slack_required_banner.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final MqttService _mqttService = MqttService.instance;
  final RealtimeHistoryController _historyController =
      RealtimeHistoryController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearBottom);
    _historyController.startRealtimeUpdates();
    unawaited(_historyController.loadInitialPage());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: SafeArea(
        child: ValueListenableBuilder<MqttConnectionState>(
          valueListenable: _mqttService.connectionState,
          builder: (context, connectionState, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: _mqttService.subscribedTopic,
              builder: (context, subscribedTopic, child) {
                return _AnalyticsContent(
                  connectionState: connectionState,
                  historyController: _historyController,
                  onRefresh: _historyController.refresh,
                  scrollController: _scrollController,
                  subscribedTopic: subscribedTopic,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _loadMoreNearBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 520) {
      unawaited(_historyController.loadNextPage());
    }
  }
}

class _AnalyticsContent extends StatelessWidget {
  final MqttConnectionState connectionState;
  final RealtimeHistoryController historyController;
  final RefreshCallback onRefresh;
  final ScrollController scrollController;
  final String? subscribedTopic;

  const _AnalyticsContent({
    required this.connectionState,
    required this.historyController,
    required this.onRefresh,
    required this.scrollController,
    this.subscribedTopic,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
            const SlackRequiredBanner(),
            const SizedBox(height: 16),
            AnalyticsSummaryCard(
              connectionState: connectionState,
              subscribedTopic: subscribedTopic,
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
            RealtimeTelemetryHistorySection(controller: historyController),
          ],
        ),
      ),
    );
  }
}
