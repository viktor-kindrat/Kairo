import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class HomeTimerCard extends StatelessWidget {
  const HomeTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.sp(32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.sp(32)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 40,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: context.sp(80),
            width: context.sp(80),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B66FF), Color(0xFF6B4EFF)],
              ),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 40),
          ),
          SizedBox(height: context.sp(24)),
          Text(
            'Deep Work',
            style: TextStyle(
              fontSize: context.sp(24),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: context.sp(8)),
          Text(
            '01:24:10',
            style: TextStyle(
              fontSize: context.sp(48),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
