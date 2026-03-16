import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class HomeTimerCard extends StatelessWidget {
  const HomeTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
          // Лампочка/Сфера з твого макета
          Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B66FF), Color(0xFF6B4EFF)],
              ),
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Deep Work',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '01:24:10',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
