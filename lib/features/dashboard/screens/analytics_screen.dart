import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/cubit/analytics_cubit.dart';
import 'package:kairo/features/dashboard/cubit/analytics_state.dart';
import 'package:kairo/features/dashboard/widgets/analytics_summary_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_database_analytics_card.dart';
import 'package:kairo/features/dashboard/widgets/realtime_telemetry_history_section.dart';
import 'package:kairo/features/mqtt/repositories/realtime_telemetry_history_repository.dart';
import 'package:kairo/features/profile/widgets/slack_required_banner.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsCubit _analyticsCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _analyticsCubit = AnalyticsCubit(
      historyRepository: context.read<RealtimeTelemetryHistoryRepository>(),
    );
    _scrollController.addListener(_loadMoreNearBottom);
    unawaited(_analyticsCubit.initialize());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _analyticsCubit.close();
    super.dispose();
  }

  void _loadMoreNearBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 520) {
      unawaited(_analyticsCubit.loadNextPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: SafeArea(
        child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          bloc: _analyticsCubit,
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: _analyticsCubit.refresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
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
                      connectionState: state.mqttConnectionState,
                      subscribedTopic: state.subscribedTopic,
                    ),
                    const SizedBox(height: 28),
                    RealtimeDatabaseAnalyticsCard(
                      summary: state.summary,
                      isLoading: !state.isInitialLoadDone,
                      requiresSignIn: state.requiresSignIn,
                    ),
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
                    RealtimeTelemetryHistorySection(
                      items: state.items,
                      isLoading: state.isLoading,
                      isInitialLoadDone: state.isInitialLoadDone,
                      requiresSignIn: state.requiresSignIn,
                      errorMessage: state.errorMessage,
                      hasMore: state.hasMore,
                      onLoadNextPage: _analyticsCubit.loadNextPage,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
