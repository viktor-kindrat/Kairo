import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_button.dart';

class SlackAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const SlackAuthButton({
    required this.onPressed,
    super.key,
    this.text = 'Continue with Slack',
  });

  @override
  Widget build(BuildContext context) {
    return KairoButton(
      text: text,
      isOutlined: true,
      icon: SvgPicture.asset(
        'assets/icons/slack_icon.svg',
        height: context.sp(20),
        width: context.sp(20),
      ),
      onPressed: onPressed,
    );
  }
}
