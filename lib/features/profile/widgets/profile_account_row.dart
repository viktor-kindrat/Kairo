import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ProfileAccountRow extends StatelessWidget {
  final Color backgroundTint;
  final Color borderTint;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const ProfileAccountRow({
    required this.backgroundTint,
    required this.borderTint,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(18),
        vertical: context.sp(22),
      ),
      child: Row(
        children: [
          Container(
            height: context.sp(56),
            width: context.sp(56),
            decoration: BoxDecoration(
              color: backgroundTint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderTint),
            ),
            child: Icon(icon, color: iconColor, size: context.sp(28)),
          ),
          SizedBox(width: context.sp(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.sp(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF9EA3AF),
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
