import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_password_input.dart';

class PasswordPairFields extends StatelessWidget {
  final TextEditingController confirmPasswordController;
  final String? confirmPasswordError;
  final String confirmPasswordHintText;
  final ValueChanged<String>? onConfirmPasswordChanged;
  final ValueChanged<String>? onPasswordChanged;
  final TextEditingController passwordController;
  final String? passwordError;
  final String passwordHintText;

  const PasswordPairFields({
    required this.confirmPasswordController,
    required this.passwordController,
    super.key,
    this.confirmPasswordError,
    this.confirmPasswordHintText = 'Confirm Password',
    this.onConfirmPasswordChanged,
    this.onPasswordChanged,
    this.passwordError,
    this.passwordHintText = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: context.sp(16),
      children: [
        AppPasswordInput(
          controller: passwordController,
          hintText: passwordHintText,
          errorText: passwordError,
          onChanged: onPasswordChanged,
        ),
        AppPasswordInput(
          controller: confirmPasswordController,
          hintText: confirmPasswordHintText,
          errorText: confirmPasswordError,
          onChanged: onConfirmPasswordChanged,
        ),
      ],
    );
  }
}
