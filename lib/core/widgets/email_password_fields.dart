import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/app_password_input.dart';

class EmailPasswordFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPasswordChanged;
  final String emailHintText;
  final String passwordHintText;

  const EmailPasswordFields({
    required this.emailController,
    required this.passwordController,
    super.key,
    this.emailError,
    this.passwordError,
    this.onEmailChanged,
    this.onPasswordChanged,
    this.emailHintText = 'Email',
    this.passwordHintText = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: context.sp(16),
      children: [
        AppEmailInput(
          controller: emailController,
          hintText: emailHintText,
          errorText: emailError,
          onChanged: onEmailChanged,
        ),
        AppPasswordInput(
          controller: passwordController,
          hintText: passwordHintText,
          errorText: passwordError,
          onChanged: onPasswordChanged,
        ),
      ],
    );
  }
}
