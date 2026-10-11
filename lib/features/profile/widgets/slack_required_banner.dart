import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';

class SlackRequiredBanner extends StatefulWidget {
  const SlackRequiredBanner({super.key});

  @override
  State<SlackRequiredBanner> createState() => _SlackRequiredBannerState();
}

class _SlackRequiredBannerState extends State<SlackRequiredBanner>
    with WidgetsBindingObserver {
  final SlackConnectionRepository _repository = SlackConnectionRepository();

  bool? _isConnected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnected != false) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.sp(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFFED7AA)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFC2410C),
            size: context.sp(22),
          ),
          SizedBox(width: context.sp(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slack integration required',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.sp(4)),
                Text(
                  'Cube data will not be read or saved until Slack is '
                  'connected in your profile.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: context.sp(13),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _repository.getStatus();

      if (mounted) {
        setState(() => _isConnected = status.connected);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isConnected = false);
      }
    }
  }
}
