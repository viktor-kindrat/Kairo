import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

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
                const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  backText,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        Image.asset('assets/images/app_icon.png', height: 28, width: 28),
      ],
    );
  }
}
