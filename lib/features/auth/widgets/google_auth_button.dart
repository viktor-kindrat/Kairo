import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_button.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const GoogleAuthButton({
    required this.onPressed,
    super.key,
    this.text = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return KairoButton(
      text: text,
      isOutlined: true,
      icon: Container(
        height: context.sp(20),
        width: context.sp(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'G',
          style: TextStyle(
            color: const Color(0xFF4285F4),
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
