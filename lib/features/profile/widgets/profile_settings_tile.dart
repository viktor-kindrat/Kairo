import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.sp(20),
        vertical: context.sp(4),
      ),
      leading: Container(
        padding: EdgeInsets.all(context.sp(8)),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(context.sp(10)),
        ),
        child: Icon(icon, color: AppColors.primary, size: context.sp(20)),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: context.sp(15), fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: context.sp(12),
                color: AppColors.textLight,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: context.sp(14),
            color: AppColors.textLight,
          ),
    );
  }
}
