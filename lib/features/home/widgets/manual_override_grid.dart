import 'package:flutter/material.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/home/widgets/kairo_activity_item.dart';

class ManualOverrideGrid extends StatelessWidget {
  final List<StatusPreset> presets;
  final ValueChanged<StatusPreset> onPresetTap;
  final ValueChanged<StatusPreset> onPresetEdit;

  const ManualOverrideGrid({
    required this.presets,
    required this.onPresetTap,
    required this.onPresetEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: presets
          .map(
            (preset) => KairoActivityItem(
              icon: iconForStatusKey(preset.iconKey),
              label: preset.label,
              isActive: preset.isActive,
              onTap: () => onPresetTap(preset),
              onLongPress: () => onPresetEdit(preset),
            ),
          )
          .toList(),
    );
  }
}
