import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class TextSplitter extends StatelessWidget {
  final String content;

  const TextSplitter({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.border, thickness: context.sp(1)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
          child: Text(
            content,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: context.sp(14),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.border, thickness: context.sp(1)),
        ),
      ],
    );
  }
}
