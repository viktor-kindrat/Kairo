import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class EmptyTelemetryCard extends StatelessWidget {
  const EmptyTelemetryCard({super.key});

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
