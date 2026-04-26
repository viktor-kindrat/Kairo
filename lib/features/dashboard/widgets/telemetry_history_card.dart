import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/widgets/history_badge.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

class TelemetryHistoryCard extends StatelessWidget {
  final CubeTelemetryEntry entry;

  const TelemetryHistoryCard({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TelemetryCardHeader(entry: entry),
          if (entry.statusLabel != null || entry.batteryPercent != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (entry.statusLabel != null)
                  HistoryBadge(
                    label: entry.resolvedStatusLabel,
                    icon: entry.statusIconKey == null
                        ? null
                        : iconForStatusKey(entry.statusIconKey!),
                  ),
                if (entry.batteryPercent != null)
                  HistoryBadge(label: 'Battery ${entry.batteryPercent}%'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            entry.rawPayload,
            style: TextStyle(
              fontSize: context.sp(13),
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryCardHeader extends StatelessWidget {
  final CubeTelemetryEntry entry;

  const _TelemetryCardHeader({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          entry.orientationLabel,
          style: TextStyle(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Text(
          entry.displayTimestamp,
          style: TextStyle(
            fontSize: context.sp(12),
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
