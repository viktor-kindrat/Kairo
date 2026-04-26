import 'package:flutter/material.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/widgets/empty_presets_card.dart';
import 'package:kairo/features/home/widgets/manual_override_grid.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

class ManualOverrideSection extends StatelessWidget {
  final ValueNotifier<CubeTelemetryEntry?> latestTelemetry;
  final Future<void>? presetsFuture;
  final List<StatusPreset> presets;
  final ValueChanged<StatusPreset> onPresetEdit;
  final ValueChanged<StatusPreset> onPresetTap;

  const ManualOverrideSection({
    required this.latestTelemetry,
    required this.onPresetEdit,
    required this.onPresetTap,
    required this.presets,
    required this.presetsFuture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: presetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            presets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<CubeTelemetryEntry?>(
          valueListenable: latestTelemetry,
          builder: (context, telemetry, child) {
            if (presets.isEmpty) {
              return const EmptyPresetsCard();
            }

            return ManualOverrideGrid(
              presets: presets,
              activeOrientationLabel: telemetry?.orientationLabel,
              onPresetTap: onPresetTap,
              onPresetEdit: onPresetEdit,
            );
          },
        );
      },
    );
  }
}
