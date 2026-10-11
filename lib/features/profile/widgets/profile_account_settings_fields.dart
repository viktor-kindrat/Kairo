import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/kairo_input.dart';

class ProfileAccountSettingsFields extends StatelessWidget {
  final TextEditingController emailController;
  final String? emailError;
  final TextEditingController fullNameController;
  final String? fullNameError;
  final ValueChanged<String> onChanged;
  final TextEditingController roleTitleController;
  final String? roleTitleError;

  const ProfileAccountSettingsFields({
    required this.emailController,
    required this.fullNameController,
    required this.onChanged,
    required this.roleTitleController,
    this.emailError,
    this.fullNameError,
    this.roleTitleError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KairoInput(
          controller: fullNameController,
          hintText: 'Full Name',
          keyboardType: TextInputType.name,
          errorText: fullNameError,
          onChanged: onChanged,
        ),
        SizedBox(height: context.sp(16)),
        AppEmailInput(
          controller: emailController,
          errorText: emailError,
          onChanged: onChanged,
        ),
        SizedBox(height: context.sp(16)),
        KairoInput(
          controller: roleTitleController,
          hintText: 'Role Title',
          errorText: roleTitleError,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
