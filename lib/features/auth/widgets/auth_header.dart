import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class AuthHeader extends StatelessWidget {
  final String backText;
  final VoidCallback? onBackPressed;
  final bool? backButtonRemoved;

  const AuthHeader({
    super.key,
    this.backText = 'Back',
    this.onBackPressed,
    this.backButtonRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (backButtonRemoved != true)
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.pop(context),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  size: context.sp(16),
                  color: AppColors.textLight,
                ),
                SizedBox(width: context.sp(4)),
                Text(
                  backText,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: context.sp(16),
                  ),
                ),
              ],
            ),
          ),
        Image.asset(
          'assets/images/app_icon.png',
          height: context.sp(28),
          width: context.sp(28),
        ),
      ],
    );
  }
}
