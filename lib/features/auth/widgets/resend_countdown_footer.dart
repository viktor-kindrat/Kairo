import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';

class ResendCountdownFooter extends StatelessWidget {
  final String actionText;
  final bool isBusy;
  final VoidCallback onTap;
  final String prefixText;
  final int secondsRemaining;

  const ResendCountdownFooter({
    required this.onTap,
    required this.secondsRemaining,
    super.key,
    this.actionText = 'Resend',
    this.isBusy = false,
    this.prefixText = 'Didn\'t receive it?',
  });

  @override
  Widget build(BuildContext context) {
    if (secondsRemaining > 0) {
      return Text(
        '$prefixText $actionText in ${secondsRemaining}s',
        style: const TextStyle(color: AppColors.textLight, fontSize: 14),
      );
    }

    if (isBusy) {
      return Text(
        '$prefixText Resending...',
        style: const TextStyle(color: AppColors.textLight, fontSize: 14),
      );
    }

    return AuthFooter(
      message: '$prefixText ',
      actionText: actionText,
      onTap: onTap,
    );
  }
}
