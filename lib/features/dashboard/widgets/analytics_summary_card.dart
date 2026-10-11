import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final MqttConnectionState connectionState;
  final String? subscribedTopic;

  const AnalyticsSummaryCard({
    required this.connectionState,
    this.subscribedTopic,
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
          Text(
            'MQTT Connection',
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          _ConnectionStateLabel(
            connectionState: connectionState,
            isConnected: isConnected,
          ),
          if (subscribedTopic != null) ...[
            const SizedBox(height: 12),
            Text(
              'Subscribed topic',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: context.sp(12),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              subscribedTopic!,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: context.sp(13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
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
