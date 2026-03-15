import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class TextSplitter extends StatelessWidget {
  final String content;

  const TextSplitter({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            content,
            style: const TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}
