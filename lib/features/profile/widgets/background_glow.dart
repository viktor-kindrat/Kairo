import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class BackgroundGlow extends StatelessWidget {
  final double size;

  const BackgroundGlow({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              AppColors.primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
