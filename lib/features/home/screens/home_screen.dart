import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';
import 'package:kairo/features/home/cubit/home_activity_cubit.dart';
import 'package:kairo/features/home/cubit/home_activity_state.dart';
import 'package:kairo/features/home/cubit/status_preset_cubit.dart';
import 'package:kairo/features/home/cubit/status_preset_state.dart';
import 'package:kairo/features/home/repositories/home_activity_repository.dart';
import 'package:kairo/features/home/utils/duration_formatters.dart';
import 'package:kairo/features/home/utils/home_activity_calculator.dart';
import 'package:kairo/features/home/widgets/focus_summary_section.dart';
import 'package:kairo/features/home/widgets/home_header.dart';
import 'package:kairo/features/home/widgets/home_timer_card.dart';
import 'package:kairo/features/profile/widgets/slack_required_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _calculator = HomeActivityCalculator();

  late final HomeActivityCubit _activityCubit;
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _activityCubit = HomeActivityCubit(
      context.read<HomeActivityRepository>(),
    );
    unawaited(_activityCubit.start());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = DateTime.now();
      final nextDayStart = DateTime(next.year, next.month, next.day);
      final currentDayStart = DateTime(_now.year, _now.month, _now.day);
      setState(() => _now = next);
      if (nextDayStart != currentDayStart) {
        unawaited(_activityCubit.onDayRollover(nextDayStart));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activityCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user =
        authState is AuthAuthenticated ? authState.user : null;
    final presets = context.watch<StatusPresetCubit>().state.presets;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeActivityCubit, HomeActivityState>(
          bloc: _activityCubit,
          builder: (context, activityState) {
            final activity = _calculator.calculate(
              carryInEvent: activityState is HomeActivityLoaded
                  ? activityState.carryInEvent
                  : null,
              dayStart: activityState is HomeActivityLoaded
                  ? activityState.dayStart
                  : DateTime(_now.year, _now.month, _now.day),
              errorMessage: activityState is HomeActivityLoaded
                  ? activityState.errorMessage
                  : null,
              events: activityState is HomeActivityLoaded
                  ? activityState.todayEvents
                  : const [],
              isLoading: activityState is HomeActivityLoading,
              latestEvent: activityState is HomeActivityLoaded
                  ? activityState.latestEvent
                  : null,
              now: _now,
              presets: presets,
              requiresSignIn: activityState is HomeActivityLoaded &&
                  activityState.requiresSignIn,
            );

            return RefreshIndicator(
              onRefresh: _activityCubit.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      batteryPercent: activity.latestBatteryPercent,
                      now: activity.now,
                      user: user,
                    ),
                    const SizedBox(height: 20),
                    const SlackRequiredBanner(),
                    const SizedBox(height: 32),
                    HomeTimerCard(activity: activity),
                    const SizedBox(height: 32),
                    KairoSectionHeader(
                      title: 'Today\'s Focus',
                      actionText:
                          '${formatCompactDuration(activity.totalDuration)} '
                          'total',
                    ),
                    const SizedBox(height: 20),
                    FocusSummarySection(activity: activity),
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
