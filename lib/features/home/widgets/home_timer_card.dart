import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/slack_emoji.dart';
import 'package:kairo/features/home/models/home_activity_status.dart';
import 'package:kairo/features/home/utils/duration_formatters.dart';

class HomeTimerCard extends StatelessWidget {
  final HomeActivitySnapshot activity;

  const HomeTimerCard({required this.activity, super.key});

  @override
  Widget build(BuildContext context) {
    final currentPreset = activity.currentPreset;
    final statusLabel = _statusLabel();
    final timerLabel = activity.isLoading
        ? '--:--:--'
        : formatTimerDuration(activity.currentElapsed);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.sp(32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(32)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: context.sp(80),
            width: context.sp(80),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B66FF), Color(0xFF6B4EFF)],
              ),
            ),
            child: Center(
              child: Text(
                slackEmojiGlyph(currentPreset?.slackEmojiCode),
                style: TextStyle(fontSize: context.sp(36)),
              ),
            ),
          ),
          SizedBox(height: context.sp(24)),
          Text(
            statusLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(24),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: context.sp(8)),
          Text(
            timerLabel,
            style: TextStyle(
              fontSize: context.sp(48),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel() {
    if (activity.requiresSignIn) {
      return 'Sign in to track focus';
    }

    if (activity.currentPreset != null) {
      return activity.currentPreset!.label;
    }

    if (activity.hasActivityEvents) {
      return activity.isLoading ? 'Loading statuses' : 'Status not configured';
    }

    return activity.isLoading ? 'Loading status' : 'Waiting for cube';
  }
}
