import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

class KairoStepsList extends StatelessWidget {
  final List<String> steps;

  const KairoStepsList({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FD), // Твій фірмовий світло-фіолетовий
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          int idx = entry.key;
          String text = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: idx == steps.length - 1 ? 0 : 20),
            child: Row(
              children: [
                // Кружечок з номером
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Текст кроку
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
