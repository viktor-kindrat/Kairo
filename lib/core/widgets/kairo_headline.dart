import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoHeadline extends StatelessWidget {
  final String headline;
  final String? subHeadline;

  const KairoHeadline({required this.headline, super.key, this.subHeadline});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            headline,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (subHeadline != null)
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              subHeadline!,
              textAlign: TextAlign.left,

              style: const TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
          ),
      ],
    );
  }
}
