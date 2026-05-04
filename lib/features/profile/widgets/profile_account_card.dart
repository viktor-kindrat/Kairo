import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/profile/widgets/profile_account_row.dart';

class ProfileAccountCard extends StatelessWidget {
  final LocalUser user;
  final VoidCallback onEdit;
  final VoidCallback onChangePassword;

  const ProfileAccountCard({
    required this.user,
    required this.onEdit,
    required this.onChangePassword,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAccountRow(
            backgroundTint: const Color(0xFFEFF5FF),
            borderTint: const Color(0xFFCFE0FF),
            iconColor: const Color(0xFF356CF5),
            icon: Icons.email_outlined,
            title: user.email,
            subtitle: 'Email address',
            trailing: GestureDetector(
              onTap: onEdit,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F1F6)),
          ProfileAccountRow(
            backgroundTint: const Color(0xFFF5EEFF),
            borderTint: const Color(0xFFE0CCFF),
            iconColor: AppColors.primary,
            icon: Icons.lock_outline_rounded,
            title: 'Password',
            subtitle: maskPassword(user.password),
            trailing: GestureDetector(
              onTap: onChangePassword,
              child: Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
