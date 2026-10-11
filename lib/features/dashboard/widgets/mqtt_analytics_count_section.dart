import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class MqttAnalyticsCountSection extends StatelessWidget {
  final Map<String, int> counts;
  final String title;

  const MqttAnalyticsCountSection({
    required this.counts,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (counts.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedCounts = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedCounts.map((entry) {
            return _CountChip(label: entry.key, value: entry.value);
          }).toList(),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int value;

  const _CountChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$label: $value',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: context.sp(12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
