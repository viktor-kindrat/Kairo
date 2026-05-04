import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class MetricChip extends StatelessWidget {
  final String? emoji;
  final String label;
  final String value;
  final IconData? icon;

  const MetricChip({
    required this.label,
    required this.value,
    this.emoji,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: context.sp(140)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: context.sp(11),
              color: AppColors.textLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: TextStyle(fontSize: context.sp(16))),
                const SizedBox(width: 8),
              ],
              if (icon != null) ...[
                Icon(icon, size: context.sp(16), color: AppColors.primary),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
