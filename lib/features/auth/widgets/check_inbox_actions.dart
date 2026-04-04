import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/utils/open_mail_client.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/auth/widgets/resend_countdown_footer.dart';

class CheckInboxActions extends StatelessWidget {
  final VoidCallback onResend;
  final int secondsRemaining;

  const CheckInboxActions({
    required this.onResend,
    required this.secondsRemaining,
    super.key,
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

        ResendCountdownFooter(
          secondsRemaining: secondsRemaining,
          onTap: onResend,
        ),

        KairoButton(
          text: 'Back to Log In',
          isOutlined: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.auth),
        ),
      ],
    );
  }
}
