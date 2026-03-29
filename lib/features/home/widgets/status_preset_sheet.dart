import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';

class StatusPresetSheet extends StatefulWidget {
  final String? initialLabel;
  final String initialIconKey;
  final String submitLabel;
  final Future<void> Function({required String label, required String iconKey})
  onSubmit;
  final VoidCallback? onDelete;

  const StatusPresetSheet({
    required this.initialIconKey,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
    this.initialLabel,
    this.onDelete,
  });

  @override
  State<StatusPresetSheet> createState() => _StatusPresetSheetState();
}

class _StatusPresetSheetState extends State<StatusPresetSheet> {
  late final TextEditingController _labelController;
  late String _selectedIconKey;
  String? _labelError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialLabel ?? '');
    _selectedIconKey = widget.initialIconKey;
  }

  Future<void> _submit() async {
    final label = _labelController.text.trim();

    if (label.isEmpty) {
      setState(() {
        _labelError = 'Please enter a preset label.';
      });
      return;
    }

    setState(() {
      _labelError = null;
      _isSaving = true;
    });

    await widget.onSubmit(label: label, iconKey: _selectedIconKey);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: widget.initialLabel == null ? 'Add Preset' : 'Edit Preset',
      children: [
        KairoInput(
          controller: _labelController,
          hintText: 'Preset label',
          errorText: _labelError,
          onChanged: (_) {
            if (_labelError != null) {
              setState(() {
                _labelError = null;
              });
            }
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedIconKey,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            items: statusIconOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.key,
                    child: Row(
                      spacing: 12,
                      children: [
                        Icon(option.icon, color: AppColors.primary),
                        Text(option.label),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedIconKey = value;
              });
            },
          ),
        ),
        SizedBox(height: context.sp(20)),
        KairoButton(
          text: _isSaving ? 'Saving...' : widget.submitLabel,
          isLoading: _isSaving,
          onPressed: _submit,
        ),
        if (widget.onDelete != null) ...[
          SizedBox(height: context.sp(12)),
          KairoButton(
            text: 'Delete Preset',
            isOutlined: true,
            onPressed: widget.onDelete,
          ),
        ],
      ],
    );
  }
}
