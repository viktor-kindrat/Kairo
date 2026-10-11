import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class NoProfileView extends StatelessWidget {
  const NoProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'No active profile.',
          style: TextStyle(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
