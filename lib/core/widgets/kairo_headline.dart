import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

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
            style: TextStyle(
              fontSize: context.sp(36),
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(height: context.sp(8)),

        if (subHeadline != null)
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              subHeadline!,
              textAlign: TextAlign.left,

              style: TextStyle(
                fontSize: context.sp(16),
                color: AppColors.textLight,
              ),
            ),
          ),
      ],
    );
  }
}
