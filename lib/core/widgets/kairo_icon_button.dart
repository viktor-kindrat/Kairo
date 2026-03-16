import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;

  const KairoIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: AppColors.background,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border, width: 4),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: IconTheme(
              data: const IconThemeData(color: AppColors.textLight, size: 28),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
