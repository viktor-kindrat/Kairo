import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/core/widgets/text_splitter.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';

class SignInForm extends StatelessWidget {
  final VoidCallback onSwitchTab;

  const SignInForm({required this.onSwitchTab, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KairoInput(
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const KairoInput(hintText: 'Password', isPassword: true),
        const SizedBox(height: 16),

        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        KairoButton(
          text: 'Log In',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        const SizedBox(height: 32),

        const TextSplitter(content: 'or'),

        const SizedBox(height: 32),

        KairoButton(
          text: 'Continue with Slack',
          isOutlined: true,
          icon: SvgPicture.asset(
            'assets/icons/slack_icon.svg',
            height: 20,
            width: 20,
          ),
          onPressed: () {},
        ),
        const SizedBox(height: 40),

        AuthFooter(
          message: 'New to Kairo?',
          actionText: 'Sign Up',
          onTap: onSwitchTab,
        ),
      ],
    );
  }
}
