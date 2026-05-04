import 'package:flutter/material.dart';
import 'package:kairo/core/utils/open_mail_client.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/email_delivery_hero.dart';
import 'package:kairo/features/auth/widgets/resend_countdown_footer.dart';

class VerifyEmailContent extends StatelessWidget {
  final bool isResending;
  final bool isVerifying;
  final VoidCallback onBackPressed;
  final VoidCallback onConfirmPressed;
  final VoidCallback onResendPressed;
  final String pendingEmail;
  final ValueNotifier<int> resendCountdown;

  const VerifyEmailContent({
    required this.isResending,
    required this.isVerifying,
    required this.onBackPressed,
    required this.onConfirmPressed,
    required this.onResendPressed,
    required this.pendingEmail,
    required this.resendCountdown,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(backText: 'Sign Up', onBackPressed: onBackPressed),
          const SizedBox(height: 40),
          EmailDeliveryHero(
            email: pendingEmail,
            headline: 'Verify your email.',
            subHeadline: 'We sent a verification link to your email address',
          ),
          const SizedBox(height: 32),
          KairoButton(
            text: isVerifying
                ? 'Checking Verification...'
                : 'I Confirmed My Email',
            isLoading: isVerifying,
            onPressed: onConfirmPressed,
          ),
          const SizedBox(height: 16),
          KairoButton(
            text: 'Open Email App',
            isOutlined: true,
            onPressed: () => MailUtils.openMailApp(context),
          ),
          SizedBox(height: context.sp(24)),
          Center(
            child: ValueListenableBuilder<int>(
              valueListenable: resendCountdown,
              builder: (context, secondsRemaining, child) {
                return ResendCountdownFooter(
                  secondsRemaining: secondsRemaining,
                  isBusy: isResending,
                  onTap: onResendPressed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
