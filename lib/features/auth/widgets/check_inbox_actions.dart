import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/open_mail_client.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';

class CheckInboxActions extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback startTimer;

  const CheckInboxActions({
    super.key,
    required this.secondsRemaining,
    required this.startTimer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      children: [
        KairoButton(
          text: 'Open Email App',
          icon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
          onPressed: () => MailUtils.openMailApp(context),
        ),

        _buildFooter(),

        KairoButton(
          text: 'Back to Log In',
          isOutlined: true,
          onPressed: () => Navigator.pushNamed(context, '/auth'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    if (secondsRemaining > 0) {
      return Text(
        "Didn't receive it? Resend in ${secondsRemaining}s",
        style: const TextStyle(color: AppColors.textLight, fontSize: 14),
      );
    } else {
      return AuthFooter(
        message: "Didn't receive it? ",
        actionText: 'Resend',
        onTap: startTimer,
      );
    }
  }
}
