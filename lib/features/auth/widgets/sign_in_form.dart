import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
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
        SizedBox(height: context.sp(16)),
        const KairoInput(hintText: 'Password', isPassword: true),
        SizedBox(height: context.sp(16)),

        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: context.sp(24)),

        KairoButton(
          text: 'Log In',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),
        SizedBox(height: context.sp(32)),

        const TextSplitter(content: 'or'),

        SizedBox(height: context.sp(32)),

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
        SizedBox(height: context.sp(40)),

        AuthFooter(
          message: 'New to Kairo?',
          actionText: 'Sign Up',
          onTap: onSwitchTab,
        ),
      ],
    );
  }
}
