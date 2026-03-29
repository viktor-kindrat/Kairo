import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class KairoActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const KairoActivityItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF3EFFF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: context.sp(36),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.sp(14),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
