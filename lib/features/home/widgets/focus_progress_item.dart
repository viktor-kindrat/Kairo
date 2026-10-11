import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class FocusProgressItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String time;
  final double progress; // 0.0 - 1.0
  final Color color;

  const FocusProgressItem({
    required this.emoji,
    required this.label,
    required this.time,
    required this.progress,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(emoji, style: TextStyle(fontSize: context.sp(14))),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: context.sp(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: context.sp(13),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.sp(4)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.sp(6),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
