import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoInfoCard extends StatelessWidget {
  final String text;
  final String? boldText;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const KairoInfoCard({
    required this.text,
    super.key,
    this.boldText,
    this.icon = Icons.info_outline,
    this.backgroundColor = const Color(0xFFF8F8FD),
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  height: 1.5,
                ),
                children: _buildTextSpans(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    if (boldText == null || !text.contains(boldText!)) {
      return [TextSpan(text: text)];
    }

    final parts = text.split(boldText!);
    return [
      TextSpan(text: parts[0]),
      TextSpan(
        text: boldText,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (parts.length > 1) TextSpan(text: parts[1]),
    ];
  }
}
