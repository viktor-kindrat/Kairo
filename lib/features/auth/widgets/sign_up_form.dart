import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/core/widgets/text_splitter.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';

class SignUpForm extends StatelessWidget {
  final VoidCallback onSwitchTab;

  const SignUpForm({required this.onSwitchTab, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          spacing: 16,
          children: [
            KairoInput(hintText: 'Full Name', keyboardType: TextInputType.name),
            KairoInput(
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            KairoInput(hintText: 'Password', isPassword: true),
            KairoInput(hintText: 'Confirm password', isPassword: true),
          ],
        ),
        const SizedBox(height: 24),

        Column(
          spacing: 32,
          children: [
            KairoButton(
              text: 'Sign Up',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/main');
              },
            ),

            const TextSplitter(content: 'or'),

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
          ],
        ),

        const SizedBox(height: 40),

        AuthFooter(
          message: 'Already have an account? ',
          actionText: 'Log In',
          onTap: onSwitchTab,
        ),
      ],
    );
  }
}
