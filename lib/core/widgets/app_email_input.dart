import 'package:flutter/material.dart';
import 'package:kairo/core/widgets/kairo_input.dart';

class AppEmailInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const AppEmailInput({
    super.key,
    this.controller,
    this.errorText,
    this.hintText = 'Email',
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return KairoInput(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.emailAddress,
      errorText: errorText,
      onChanged: onChanged,
      readOnly: readOnly,
    );
  }
}
