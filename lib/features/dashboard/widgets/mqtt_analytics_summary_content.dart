import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/widgets/metric_chip.dart';
import 'package:kairo/features/dashboard/widgets/mqtt_analytics_count_section.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';

class MqttAnalyticsSummaryContent extends StatelessWidget {
  final MqttAnalyticsSummary summary;

  const MqttAnalyticsSummaryContent({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saved MQTT Analytics',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: context.sp(18),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricChip(label: 'Events', value: '${summary.totalEvents}'),
              MetricChip(
                label: 'Last Seen',
                value: _dateLabel(summary.lastSeenAt),
              ),
              MetricChip(
                label: 'Top Orientation',
                value: summary.topOrientation ?? 'N/A',
              ),
              MetricChip(
                label: 'Top Status',
                value: summary.topStatus ?? 'N/A',
              ),
              MetricChip(label: 'Avg Battery', value: _averageBatteryLabel()),
              MetricChip(label: 'Battery Range', value: _batteryRangeLabel()),
            ],
          ),
          if (summary.orientationCounts.isNotEmpty ||
              summary.statusCounts.isNotEmpty) ...[
            const SizedBox(height: 20),
            MqttAnalyticsCountSection(
              title: 'Orientations',
              counts: summary.orientationCounts,
            ),
            const SizedBox(height: 16),
            MqttAnalyticsCountSection(
              title: 'Statuses',
              counts: summary.statusCounts,
            ),
          ],
        ],
      ),
    );
  }

  String _averageBatteryLabel() {
    if (summary.batterySamples == 0) {
      return 'N/A';
    }

    return '${summary.averageBattery.toStringAsFixed(1)}%';
  }

  String _batteryRangeLabel() {
    if (summary.batterySamples == 0) {
      return 'N/A';
    }

    return '${summary.batteryMin ?? 0}%-${summary.batteryMax ?? 0}%';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    final localDate = date.toLocal();
    final hours = localDate.hour.toString().padLeft(2, '0');
    final minutes = localDate.minute.toString().padLeft(2, '0');
    final seconds = localDate.second.toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }
}
