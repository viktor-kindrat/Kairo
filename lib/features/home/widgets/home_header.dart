import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_icon_button.dart';
import 'package:kairo/core/widgets/kairo_pill.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';

class HomeHeader extends StatelessWidget {
  final LocalUser? user;
  final ValueNotifier<CubeTelemetryEntry?> latestTelemetry;

  const HomeHeader({
    required this.latestTelemetry,
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFF9EA0AE),
                fontSize: context.sp(13),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<CubeTelemetryEntry?>(
          valueListenable: latestTelemetry,
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
