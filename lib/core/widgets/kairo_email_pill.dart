import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoEmailPill extends StatelessWidget {
  final String email;

  const KairoEmailPill({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              email,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
