import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/slack_emoji.dart';
import 'package:kairo/features/home/models/home_activity_status.dart';
import 'package:kairo/features/home/utils/duration_formatters.dart';
import 'package:kairo/features/home/widgets/focus_progress_item.dart';

class FocusSummarySection extends StatelessWidget {
  final HomeActivitySnapshot activity;

  const FocusSummarySection({required this.activity, super.key});

  @override
  Widget build(BuildContext context) {
    final statuses = activity.statuses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 20)],
      ),
      child: Column(
        children: [
          if (statuses.isEmpty)
            _FocusMessage(activity: activity)
          else
            ...statuses.indexed.map((entry) {
              final index = entry.$1;
              final status = entry.$2;

              return FocusProgressItem(
                color: _progressColor(index),
                emoji: slackEmojiGlyph(status.preset.slackEmojiCode),
                label: status.preset.label,
                progress: status.progress,
                time: formatCompactDuration(status.duration),
              );
            }),
        ],
      ),
    );
  }

  Color _progressColor(int index) {
    const colors = [
      AppColors.primary,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];

    return colors[index % colors.length];
  }
}

class _FocusMessage extends StatelessWidget {
  final HomeActivitySnapshot activity;

  const _FocusMessage({required this.activity});

  @override
  Widget build(BuildContext context) {
    final message = activity.requiresSignIn
        ? 'Sign in to load today\'s focus.'
        : activity.errorMessage ?? 'No cube statuses yet.';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: context.sp(14),
          height: 1.4,
        ),
      ),
    );
  }
}
