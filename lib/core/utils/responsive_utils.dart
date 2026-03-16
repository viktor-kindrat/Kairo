import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  bool get isTablet => MediaQuery.of(this).size.width > 600;

  double get scaleFactor => isTablet ? 1.4 : 1.0;

  double sp(double size) => size * scaleFactor;
}
