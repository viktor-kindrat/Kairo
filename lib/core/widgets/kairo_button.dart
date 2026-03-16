import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class KairoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool fullWidth;
  final Widget? icon;

  const KairoButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isOutlined = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            minimumSize: Size(fullWidth ? double.infinity : 0, context.sp(56)),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.sp(16)),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlack,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: Size(fullWidth ? double.infinity : 0, context.sp(56)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.sp(16)),
            ),

            disabledBackgroundColor: AppColors.accentBlack.withValues(
              alpha: 0.7,
            ),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            height: context.sp(20),
            width: context.sp(20),
            child: CircularProgressIndicator(
              strokeWidth: context.sp(2.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.primary : Colors.white,
              ),
            ),
          ),
          SizedBox(width: context.sp(12)),
        ] else if (icon != null) ...[
          icon!,
          SizedBox(width: context.sp(12)),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w600,
            color: isOutlined ? Colors.black : Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: content,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: content,
          );
  }
}
