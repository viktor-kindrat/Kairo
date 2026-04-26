import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/home/widgets/status_preset_sheet.dart';

Future<void> showStatusPresetEditor({
  required BuildContext context,
  StatusPreset? preset,
}) async {
  final statuses = context.statuses;
  final defaultIconKey = statuses.presets.isEmpty
      ? defaultStatusIconKey
      : statuses.presets.first.iconKey;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    builder: (sheetContext) {
      return StatusPresetSheet(
        initialLabel: preset?.label,
        initialIconKey: preset?.iconKey ?? defaultIconKey,
        submitLabel: preset == null ? 'Save Preset' : 'Save Changes',
        onSubmit: ({required label, required iconKey}) async {
          await _savePreset(context, preset, label, iconKey);
        },
        onDelete: preset == null
            ? null
            : () async {
                await _deletePreset(context, sheetContext, preset.id);
              },
      );
    },
  );
}

Future<void> _deletePreset(
  BuildContext context,
  BuildContext sheetContext,
  String presetId,
) async {
  try {
    await context.statuses.remove(presetId);

    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
  } catch (error) {
    if (context.mounted) {
      context.showErrorSnackBar(error.toString());
    }
  }
}

Future<void> _savePreset(
  BuildContext context,
  StatusPreset? preset,
  String label,
  String iconKey,
) async {
  try {
    if (preset == null) {
      await context.statuses.create(label: label, iconKey: iconKey);
      return;
    }

    await context.statuses.update(
      presetId: preset.id,
      label: label,
      iconKey: iconKey,
    );
  } catch (error) {
    if (context.mounted) {
      context.showErrorSnackBar(error.toString());
    }
  }
}
