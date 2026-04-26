import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/widgets/metric_chip.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/mqtt/constants/cube_side_config.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final MqttConnectionState connectionState;
  final CubeTelemetryEntry? latestEntry;

  const AnalyticsSummaryCard({
    required this.connectionState,
    required this.latestEntry,
    super.key,
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
          _ConnectionStateLabel(
            connectionState: connectionState,
            isConnected: isConnected,
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
              MetricChip(
                label: 'Orientation',
                value: latestEntry?.orientationLabel ?? 'Unknown',
                icon: cubeSideIconForValue(latestEntry?.orientation),
              ),
              MetricChip(
                label: 'Status',
                value: latestEntry?.resolvedStatusLabel ?? 'Not provided',
                icon: latestEntry?.statusIconKey == null
                    ? null
                    : iconForStatusKey(latestEntry!.statusIconKey!),
              ),
              MetricChip(
                label: 'Battery',
                value: latestEntry?.batteryPercent == null
                    ? 'N/A'
                    : '${latestEntry!.batteryPercent}%',
              ),
              MetricChip(label: 'Vector', value: _vectorLabel(latestEntry)),
            ],
          ),
        ],
      ),
    );
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

class _ConnectionStateLabel extends StatelessWidget {
  final MqttConnectionState connectionState;
  final bool isConnected;

  const _ConnectionStateLabel({
    required this.connectionState,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  String _connectionLabel(MqttConnectionState state) {
    return switch (state) {
      MqttConnectionState.connecting => 'Connecting',
      MqttConnectionState.connected => 'Connected',
      MqttConnectionState.disconnected => 'Disconnected',
      MqttConnectionState.disconnecting => 'Disconnecting',
      MqttConnectionState.faulted => 'Faulted',
    };
  }
}
