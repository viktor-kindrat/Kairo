import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class AuthFooter extends StatelessWidget {
  final String message;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooter({
    required this.message,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          Text(
            message,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: context.sp(14),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
