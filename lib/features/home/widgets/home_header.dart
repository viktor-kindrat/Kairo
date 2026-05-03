import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_pill.dart';

class HomeHeader extends StatelessWidget {
  final int? batteryPercent;
  final DateTime now;
  final LocalUser? user;

  const HomeHeader({
    required this.now,
    required this.user,
    this.batteryPercent,
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
              _formatToday(now),
              style: TextStyle(
                color: const Color(0xFF9EA0AE),
                fontSize: context.sp(13),
              ),
            ),
          ],
        ),
        Transform.scale(
          scale: 0.9,
          child: KairoPill(
            icon: Icons.battery_2_bar_rounded,
            text: batteryPercent == null
                ? 'Cube - --%'
                : 'Cube - $batteryPercent%',
          ),
        ),
      ],
    );
  }

  String _firstName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.firstWhere((part) => part.isNotEmpty, orElse: () => 'Guest');
  }

  String _formatToday(DateTime date) {
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
    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
