import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/kairo_email_pill.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/home/utils/show_status_preset_editor.dart';
import 'package:kairo/features/home/widgets/focus_summary_section.dart';
import 'package:kairo/features/home/widgets/home_header.dart';
import 'package:kairo/features/home/widgets/home_timer_card.dart';
import 'package:kairo/features/home/widgets/manual_override_section.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MqttService _mqttService = MqttService.instance;
  Future<void>? _presetsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _presetsFuture ??= context.statuses.loadOrSeedDefaults();
  }

  Future<void> _showPresetSheet({StatusPreset? preset}) async {
    await showStatusPresetEditor(context: context, preset: preset);
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
              HomeHeader(
                user: user,
                latestTelemetry: _mqttService.latestTelemetry,
              ),
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
              const FocusSummarySection(),
              const SizedBox(height: 32),
              KairoSectionHeader(
                title: 'Manual Override',
                actionText: '+ Add',
                onActionTap: _showPresetSheet,
              ),
              const SizedBox(height: 20),
              ManualOverrideSection(
                presetsFuture: _presetsFuture,
                presets: presets,
                latestTelemetry: _mqttService.latestTelemetry,
                onPresetTap: _setActive,
                onPresetEdit: (preset) => _showPresetSheet(preset: preset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
