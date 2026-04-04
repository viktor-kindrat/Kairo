import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class AppFormSheetLayout extends StatelessWidget {
  final List<Widget> children;
  final String? description;
  final EdgeInsetsGeometry? padding;
  final String title;

  const AppFormSheetLayout({
    required this.children,
    required this.title,
    super.key,
    this.description,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              24,
              18,
              24,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Container(
                key: const Key('app_form_sheet_handle'),
                height: 4,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: context.sp(20)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(22),
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: context.sp(8)),
              Text(
                description!,
                style: TextStyle(
                  fontSize: context.sp(14),
                  color: AppColors.textLight,
                ),
              ),
            ],
            SizedBox(height: context.sp(24)),
            ...children,
          ],
        ),
      ),
    );
  }
}
