import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_icon_button.dart';
import 'package:kairo/core/widgets/kairo_pill.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/home/widgets/focus_progress_item.dart';
import 'package:kairo/features/home/widgets/home_timer_card.dart';
import 'package:kairo/features/home/widgets/manual_override_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              const HomeTimerCard(),
              const SizedBox(height: 32),
              const KairoSectionHeader(
                title: "Today's Focus",
                actionText: '6h 52m total',
              ),
              const SizedBox(height: 20),
              _buildFocusSection(),
              const SizedBox(height: 32),
              const KairoSectionHeader(
                title: 'Manual Override',
                actionText: 'Cube nearby',
              ),
              const SizedBox(height: 20),
              const ManualOverrideGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Viktor.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Text(
              'Friday, March 13, 2026',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.9,
              child: const KairoPill(
                icon: Icons.battery_2_bar_rounded,
                text: 'Cube - 85%',
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.9,
              child: const KairoIconButton(
                size: 48,
                onPressed: null,
                icon: const Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFocusSection() {
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
