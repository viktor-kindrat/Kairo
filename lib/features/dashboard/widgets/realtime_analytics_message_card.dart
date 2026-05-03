import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class RealtimeAnalyticsMessageCard extends StatelessWidget {
  final Widget? leading;
  final String message;

  const RealtimeAnalyticsMessageCard({
    required this.message,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
