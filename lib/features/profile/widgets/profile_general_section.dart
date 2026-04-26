import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/features/profile/widgets/profile_settings_tile.dart';

class ProfileGeneralSection extends StatelessWidget {
  const ProfileGeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: ProfileSettingsTile(
        icon: Icons.dark_mode_outlined,
        title: 'App Theme',
        subtitle: 'Dark mode switch',
        trailing: Switch(value: false, onChanged: (value) {}),
      ),
    );
  }
}
