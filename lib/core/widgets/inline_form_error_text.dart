import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class InlineFormErrorText extends StatelessWidget {
  final String message;

  const InlineFormErrorText({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: Colors.red,
        fontSize: context.sp(14),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
