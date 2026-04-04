import 'package:flutter/material.dart';
import 'package:kairo/core/widgets/kairo_input.dart';

class AppPasswordInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? errorText;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const AppPasswordInput({
    required this.hintText,
    super.key,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return KairoInput(
      controller: controller,
      hintText: hintText,
      isPassword: true,
      errorText: errorText,
      onChanged: onChanged,
    );
  }
}
