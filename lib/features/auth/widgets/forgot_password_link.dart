import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
