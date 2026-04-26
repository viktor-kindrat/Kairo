import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class EmptyPresetsCard extends StatelessWidget {
  const EmptyPresetsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No presets yet. Tap + Add to create your first manual override.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: context.sp(14),
          ),
        ),
      ),
    );
  }
}
