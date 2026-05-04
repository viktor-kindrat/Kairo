import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/email_delivery_hero.dart';

class CheckInboxScreen extends StatelessWidget {
  final String email;

  const CheckInboxScreen({required this.email, super.key});

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
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
              Column(
                spacing: 32,
                children: [
                  EmailDeliveryHero(
                    email: email,
                    headline: 'Check your inbox.',
                    subHeadline:
                        'We sent a password reset link to your email address',
                  ),
                  KairoButton(
                    text: 'Back to Log In',
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
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
