import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/profile/widgets/profile_avatar.dart';
import 'package:kairo/features/profile/widgets/profile_role_badge.dart';

class ProfileHero extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final LocalUser user;

  const ProfileHero({required this.onAvatarTap, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ProfileAvatar(user: user, onTap: onAvatarTap),
          SizedBox(height: context.sp(24)),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(26),
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: context.sp(14)),
          ProfileRoleBadge(roleTitle: user.roleTitle),
        ],
      ),
    );
  }
}
