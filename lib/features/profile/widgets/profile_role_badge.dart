import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ProfileRoleBadge extends StatelessWidget {
  final String roleTitle;

  const ProfileRoleBadge({required this.roleTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.proGradientEnd, AppColors.proGradientStart],
        ),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(18),
          vertical: context.sp(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFE66E),
              size: 18,
            ),
            SizedBox(width: context.sp(8)),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.sp(180)),
              child: Text(
                roleTitle.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
