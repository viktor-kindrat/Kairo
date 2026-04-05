import 'package:flutter/material.dart';

class StatusIconOption {
  final String key;
  final String label;
  final IconData icon;

  const StatusIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

const String defaultStatusIconKey = 'bolt';

const List<StatusIconOption> statusIconOptions = [
  StatusIconOption(
    key: defaultStatusIconKey,
    label: 'Deep Work',
    icon: Icons.bolt,
  ),
  StatusIconOption(
    key: 'groups_outlined',
    label: 'Meeting',
    icon: Icons.groups_outlined,
  ),
  StatusIconOption(
    key: 'coffee_outlined',
    label: 'Break',
    icon: Icons.coffee_outlined,
  ),
  StatusIconOption(
    key: 'restaurant_outlined',
    label: 'Lunch',
    icon: Icons.restaurant_outlined,
  ),
  StatusIconOption(
    key: 'lightbulb_outline',
    label: 'Ideation',
    icon: Icons.lightbulb_outline,
  ),
  StatusIconOption(
    key: 'fireplace_outlined',
    label: 'Urgent',
    icon: Icons.fireplace_outlined,
  ),
  StatusIconOption(
    key: 'fitness_center_outlined',
    label: 'Focus',
    icon: Icons.fitness_center_outlined,
  ),
  StatusIconOption(
    key: 'headphones_outlined',
    label: 'Heads Down',
    icon: Icons.headphones_outlined,
  ),
];

IconData iconForStatusKey(String iconKey) {
  final matchingOption = statusIconOptions
      .where((option) => option.key == iconKey)
      .firstOrNull;

  return matchingOption?.icon ?? Icons.circle_outlined;
}

String labelForStatusKey(String iconKey, {String fallback = 'Not provided'}) {
  final matchingOption = statusIconOptions
      .where((option) => option.key == iconKey)
      .firstOrNull;

  return matchingOption?.label ?? fallback;
}
