import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_password_input.dart';
import 'package:kairo/core/widgets/password_pair_fields.dart';

class ProfilePasswordFields extends StatelessWidget {
  final TextEditingController confirmPasswordController;
  final String? confirmPasswordError;
  final TextEditingController currentPasswordController;
  final String? currentPasswordError;
  final TextEditingController newPasswordController;
  final String? newPasswordError;
  final ValueChanged<String> onChanged;

  const ProfilePasswordFields({
    required this.confirmPasswordController,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.onChanged,
    this.confirmPasswordError,
    this.currentPasswordError,
    this.newPasswordError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPasswordInput(
          controller: currentPasswordController,
          hintText: 'Current Password',
          errorText: currentPasswordError,
          onChanged: onChanged,
        ),
        SizedBox(height: context.sp(16)),
        PasswordPairFields(
          passwordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          passwordHintText: 'New Password',
          confirmPasswordHintText: 'Confirm New Password',
          passwordError: newPasswordError,
          confirmPasswordError: confirmPasswordError,
          onPasswordChanged: onChanged,
          onConfirmPasswordChanged: onChanged,
        ),
      ],
    );
  }
}
