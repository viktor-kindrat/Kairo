import 'package:flutter/material.dart';

enum CubeSide { faceUp, faceDown, left, right, forward, backward }

class CubeSideConfig {
  final CubeSide side;
  final String value;
  final String label;
  final IconData icon;

  const CubeSideConfig({
    required this.side,
    required this.value,
    required this.label,
    required this.icon,
  });
}

const List<CubeSideConfig> cubeSideConfigs = [
  CubeSideConfig(
    side: CubeSide.faceUp,
    value: 'face_up',
    label: 'Face Up',
    icon: Icons.flip_to_front_outlined,
  ),
  CubeSideConfig(
    side: CubeSide.faceDown,
    value: 'face_down',
    label: 'Face Down',
    icon: Icons.flip_to_back_outlined,
  ),
  CubeSideConfig(
    side: CubeSide.left,
    value: 'left',
    label: 'Left',
    icon: Icons.keyboard_arrow_left_rounded,
  ),
  CubeSideConfig(
    side: CubeSide.right,
    value: 'right',
    label: 'Right',
    icon: Icons.keyboard_arrow_right_rounded,
  ),
  CubeSideConfig(
    side: CubeSide.forward,
    value: 'forward',
    label: 'Forward',
    icon: Icons.arrow_upward_rounded,
  ),
  CubeSideConfig(
    side: CubeSide.backward,
    value: 'backward',
    label: 'Backward',
    icon: Icons.arrow_downward_rounded,
  ),
];

CubeSideConfig? cubeSideConfigForValue(String? value) {
  if (value == null) {
    return null;
  }

  final normalized = value.trim().toLowerCase();

  return cubeSideConfigs
      .where((config) => config.value == normalized)
      .firstOrNull;
}

String cubeSideLabelForValue(String? value, {String fallback = 'Unknown'}) {
  return cubeSideConfigForValue(value)?.label ?? fallback;
}

IconData cubeSideIconForValue(
  String? value, {
  IconData fallback = Icons.screen_rotation_alt_outlined,
}) {
  return cubeSideConfigForValue(value)?.icon ?? fallback;
}
