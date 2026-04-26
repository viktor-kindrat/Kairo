import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/features/home/widgets/focus_progress_item.dart';

class FocusSummarySection extends StatelessWidget {
  const FocusSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 20)],
      ),
      child: const Column(
        children: [
          FocusProgressItem(
            label: 'Deep Work',
            time: '4h 12m',
            progress: 0.7,
            color: AppColors.primary,
          ),
          FocusProgressItem(
            label: 'Meetings',
            time: '1h 48m',
            progress: 0.3,
            color: Colors.blue,
          ),
          FocusProgressItem(
            label: 'Breaks',
            time: '52m',
            progress: 0.15,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
