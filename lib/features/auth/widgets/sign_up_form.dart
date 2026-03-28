import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
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
        Column(
          spacing: context.sp(16),
          children: [
            const KairoInput(
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
            ),
            const KairoInput(
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const KairoInput(hintText: 'Password', isPassword: true),
            const KairoInput(hintText: 'Confirm password', isPassword: true),
          ],
        ),
        SizedBox(height: context.sp(24)),

        Column(
          spacing: context.sp(32),
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
                height: context.sp(20),
                width: context.sp(20),
              ),
              onPressed: () {},
            ),
          ],
        ),

        SizedBox(height: context.sp(40)),

        AuthFooter(
          message: 'Already have an account? ',
          actionText: 'Log In',
          onTap: onSwitchTab,
        ),
      ],
    );
  }
}
