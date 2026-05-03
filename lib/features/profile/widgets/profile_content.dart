import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/profile/widgets/profile_account_card.dart';
import 'package:kairo/features/profile/widgets/profile_edit_button.dart';
import 'package:kairo/features/profile/widgets/profile_hero.dart';
import 'package:kairo/features/profile/widgets/slack_connection_card.dart';

class ProfileContent extends StatelessWidget {
  final LocalUser user;
  final VoidCallback onAvatarTap;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteAccount;
  final VoidCallback onEditAccount;
  final VoidCallback onLogOut;

  const ProfileContent({
    required this.onAvatarTap,
    required this.onChangePassword,
    required this.onDeleteAccount,
    required this.onEditAccount,
    required this.onLogOut,
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ProfileEditButton(onPressed: onEditAccount),
            ),
            SizedBox(height: context.sp(12)),
            ProfileHero(user: user, onAvatarTap: onAvatarTap),
            SizedBox(height: context.sp(28)),
            const _ProfileSectionTitle('INTEGRATIONS', fontSize: 18),
            SizedBox(height: context.sp(14)),
            const SlackConnectionCard(),
            SizedBox(height: context.sp(40)),
            _ProfileSectionTitle('ACCOUNT', fontSize: context.sp(18)),
            SizedBox(height: context.sp(18)),
            ProfileAccountCard(
              user: user,
              onEdit: onEditAccount,
              onChangePassword: onChangePassword,
            ),
            SizedBox(height: context.sp(28)),
            KairoButton(text: 'Log Out', onPressed: onLogOut),
            SizedBox(height: context.sp(12)),
            Center(
              child: TextButton(
                onPressed: onDeleteAccount,
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  final double fontSize;
  final String title;

  const _ProfileSectionTitle(this.title, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF9EA0AE),
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }
}
