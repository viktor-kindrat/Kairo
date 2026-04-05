import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/mqtt/constants/cube_side_config.dart';
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
                final latestEntry = telemetryHistory.isEmpty
                    ? null
                    : telemetryHistory.first;

                return SingleChildScrollView(
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
                      _AnalyticsSummaryCard(
                        connectionState: connectionState,
                        latestEntry: latestEntry,
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
                      if (telemetryHistory.isEmpty)
                        _EmptyTelemetryCard()
                      else
                        Column(
                          children: telemetryHistory
                              .map(
                                (entry) => _TelemetryHistoryCard(entry: entry),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  final MqttConnectionState connectionState;
  final CubeTelemetryEntry? latestEntry;

  const _AnalyticsSummaryCard({
    required this.connectionState,
    required this.latestEntry,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = connectionState == MqttConnectionState.connected;

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
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _connectionLabel(connectionState),
                style: TextStyle(
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w800,
                  color: isConnected
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Topic: ${MqttService.defaultTopic}',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: context.sp(13),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                label: 'Orientation',
                value: latestEntry?.orientationLabel ?? 'Unknown',
                icon: cubeSideIconForValue(latestEntry?.orientation),
              ),
              _MetricChip(
                label: 'Status',
                value: latestEntry?.resolvedStatusLabel ?? 'Not provided',
                icon: latestEntry?.statusIconKey == null
                    ? null
                    : iconForStatusKey(latestEntry!.statusIconKey!),
              ),
              _MetricChip(
                label: 'Battery',
                value: latestEntry?.batteryPercent == null
                    ? 'N/A'
                    : '${latestEntry!.batteryPercent}%',
              ),
              _MetricChip(
                label: 'Vector',
                value: _vectorLabel(latestEntry),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _connectionLabel(MqttConnectionState state) {
    switch (state) {
      case MqttConnectionState.connecting:
        return 'Connecting';
      case MqttConnectionState.connected:
        return 'Connected';
      case MqttConnectionState.disconnected:
        return 'Disconnected';
      case MqttConnectionState.disconnecting:
        return 'Disconnecting';
      case MqttConnectionState.faulted:
        return 'Faulted';
    }
  }

  String _vectorLabel(CubeTelemetryEntry? entry) {
    if (entry == null ||
        entry.x == null ||
        entry.y == null ||
        entry.z == null) {
      return 'N/A';
    }

    return 'x:${entry.x!.toStringAsFixed(2)}  '
        'y:${entry.y!.toStringAsFixed(2)}  '
        'z:${entry.z!.toStringAsFixed(2)}';
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _MetricChip({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: context.sp(140)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: context.sp(11),
              color: AppColors.textLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: context.sp(16), color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryHistoryCard extends StatelessWidget {
  final CubeTelemetryEntry entry;

  const _TelemetryHistoryCard({required this.entry});

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
          Row(
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
          ),
          if (entry.statusLabel != null || entry.batteryPercent != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (entry.statusLabel != null)
                  _HistoryBadge(
                    label: entry.resolvedStatusLabel,
                    icon: entry.statusIconKey == null
                        ? null
                        : iconForStatusKey(entry.statusIconKey!),
                  ),
                if (entry.batteryPercent != null)
                  _HistoryBadge(label: 'Battery ${entry.batteryPercent}%'),
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

class _HistoryBadge extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _HistoryBadge({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: context.sp(14), color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTelemetryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        'No cube telemetry yet. Once the cube publishes to the topic, '
        'realtime history will appear here.',
        style: TextStyle(
          fontSize: context.sp(14),
          color: AppColors.textLight,
          height: 1.5,
        ),
      ),
    );
  }
}
