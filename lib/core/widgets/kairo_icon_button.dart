import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

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
        shape: CircleBorder(
          side: BorderSide(color: AppColors.border, width: context.sp(1)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: AppColors.textLight,
                size: context.sp(28),
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
