import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/home/controllers/home_activity_controller.dart';
import 'package:kairo/features/home/utils/duration_formatters.dart';
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
  final HomeActivityController _activityController = HomeActivityController();

  @override
  void initState() {
    super.initState();
    _activityController.start();
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;
    final statusController = context.statuses;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _activityController,
          builder: (context, child) {
            final activity = _activityController.snapshotFor(
              statusController.presets,
            );

            return RefreshIndicator(
              onRefresh: _activityController.refresh,
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
