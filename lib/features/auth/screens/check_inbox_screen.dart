import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/resend_countdown_controller.dart';
import 'package:kairo/core/widgets/kairo_steps_list.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/check_inbox_actions.dart';
import 'package:kairo/features/auth/widgets/email_delivery_hero.dart';

class CheckInboxScreen extends StatefulWidget {
  final String email;

  const CheckInboxScreen({required this.email, super.key});

  @override
  State<CheckInboxScreen> createState() => _CheckInboxScreenState();
}

class _CheckInboxScreenState extends State<CheckInboxScreen> {
  late final ResendCountdownController _countdownController;

  @override
  void initState() {
    super.initState();
    _countdownController = ResendCountdownController(
      initialSeconds: resendPasswordTimer,
    )..start();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              AuthHeader(
                backText: 'Log In',
                onBackPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.auth),
              ),
              const SizedBox(height: 40),
              Column(
                spacing: 32,
                children: [
                  EmailDeliveryHero(
                    email: widget.email,
                    headline: 'Check your inbox.',
                    subHeadline: 'We\'ve sent a reset link to',
                  ),

                  const KairoStepsList(
                    steps: [
                      'Open the email from Kairo',
                      'Tap "Reset my password"',
                      'Create your new password',
                    ],
                  ),

                  ValueListenableBuilder<int>(
                    valueListenable: _countdownController,
                    builder: (context, secondsRemaining, child) {
                      return CheckInboxActions(
                        secondsRemaining: secondsRemaining,
                        onResend: _countdownController.start,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
