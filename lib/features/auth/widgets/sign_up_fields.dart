import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/core/widgets/password_pair_fields.dart';

class SignUpFields extends StatelessWidget {
  final TextEditingController confirmPasswordController;
  final String? confirmPasswordError;
  final TextEditingController emailController;
  final String? emailError;
  final TextEditingController fullNameController;
  final String? fullNameError;
  final ValueChanged<String> onChanged;
  final TextEditingController passwordController;
  final String? passwordError;

  const SignUpFields({
    required this.confirmPasswordController,
    required this.emailController,
    required this.fullNameController,
    required this.onChanged,
    required this.passwordController,
    this.confirmPasswordError,
    this.emailError,
    this.fullNameError,
    this.passwordError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: context.sp(16),
      children: [
        KairoInput(
          controller: fullNameController,
          hintText: 'Full Name',
          keyboardType: TextInputType.name,
          errorText: fullNameError,
          onChanged: onChanged,
        ),
        AppEmailInput(
          controller: emailController,
          errorText: emailError,
          onChanged: onChanged,
        ),
        PasswordPairFields(
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
          confirmPasswordHintText: 'Confirm password',
          onPasswordChanged: onChanged,
          onConfirmPasswordChanged: onChanged,
        ),
      ],
    );
  }
}
