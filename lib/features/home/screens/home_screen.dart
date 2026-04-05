import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/kairo_email_pill.dart';
import 'package:kairo/core/widgets/kairo_icon_button.dart';
import 'package:kairo/core/widgets/kairo_pill.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';
import 'package:kairo/features/home/widgets/focus_progress_item.dart';
import 'package:kairo/features/home/widgets/home_timer_card.dart';
import 'package:kairo/features/home/widgets/manual_override_grid.dart';
import 'package:kairo/features/home/widgets/status_preset_sheet.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MqttService _mqttService = MqttService.instance;

  Future<void> _showPresetSheet({StatusPreset? preset}) async {
    final defaultIconKey = context.statuses.presets.isEmpty
        ? defaultStatusIconKey
        : context.statuses.presets.first.iconKey;

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
            try {
              if (preset == null) {
                await context.statuses.create(label: label, iconKey: iconKey);
              } else {
                await context.statuses.update(
                  presetId: preset.id,
                  label: label,
                  iconKey: iconKey,
                );
              }
            } catch (error) {
              if (!mounted) {
                return;
              }

              context.showErrorSnackBar(error.toString());
            }
          },
          onDelete: preset == null
              ? null
              : () async {
                  try {
                    await context.statuses.remove(preset.id);

                    if (!sheetContext.mounted) {
                      return;
                    }

                    Navigator.pop(sheetContext);
                  } catch (error) {
                    if (!mounted) {
                      return;
                    }

                    context.showErrorSnackBar(error.toString());
                  }
                },
        );
      },
    );
  }

  Future<void> _setActive(StatusPreset preset) async {
    try {
      await context.statuses.setActive(preset.id);
    } catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;
    final presets = context.statuses.presets;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, user),
              if (user != null) ...[
                const SizedBox(height: 16),
                KairoEmailPill(email: user.email),
              ],
              const SizedBox(height: 32),
              const HomeTimerCard(),
              const SizedBox(height: 32),
              const KairoSectionHeader(
                title: 'Today\'s Focus',
                actionText: '6h 52m total',
              ),
              const SizedBox(height: 20),
              _buildFocusSection(),
              const SizedBox(height: 32),
              KairoSectionHeader(
                title: 'Manual Override',
                actionText: '+ Add',
                onActionTap: _showPresetSheet,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<CubeTelemetryEntry?>(
                valueListenable: _mqttService.latestTelemetry,
                builder: (context, telemetry, child) {
                  if (presets.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ManualOverrideGrid(
                    presets: presets,
                    activeOrientationLabel: telemetry?.orientationLabel,
                    onPresetTap: _setActive,
                    onPresetEdit: (preset) => _showPresetSheet(preset: preset),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No presets yet. Tap + Add to create your first manual override.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: context.sp(14),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocalUser? user) {
    final firstName = _firstName(user?.fullName ?? 'Guest');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $firstName.',
              style: TextStyle(
                fontSize: context.sp(24),
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              _formatToday(),
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: context.sp(13),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<CubeTelemetryEntry?>(
          valueListenable: _mqttService.latestTelemetry,
          builder: (context, telemetry, child) {
            final batteryLabel = telemetry?.batteryPercent == null
                ? 'Cube - --%'
                : 'Cube - ${telemetry!.batteryPercent}%';

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: KairoPill(
                    icon: Icons.battery_2_bar_rounded,
                    text: batteryLabel,
                  ),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 0.9,
                  child: const KairoIconButton(
                    size: 48,
                    onPressed: null,
                    icon: Icon(Icons.settings),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFocusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 20)],
      ),
      child: const Column(
        children: [
          FocusProgressItem(
            label: 'Deep Work',
            time: '4h 12m',
            progress: 0.7,
            color: AppColors.primary,
          ),
          FocusProgressItem(
            label: 'Meetings',
            time: '1h 48m',
            progress: 0.3,
            color: Colors.blue,
          ),
          FocusProgressItem(
            label: 'Breaks',
            time: '52m',
            progress: 0.15,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.firstWhere((part) => part.isNotEmpty, orElse: () => 'Guest');
  }

  String _formatToday() {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final today = DateTime.now();

    return '${weekdays[today.weekday - 1]}, '
        '${months[today.month - 1]} ${today.day}, ${today.year}';
  }
}
