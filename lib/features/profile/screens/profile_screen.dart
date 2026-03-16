import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/profile/widgets/profile_settings_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 32),
              const KairoSectionHeader(title: 'Account'),
              const ProfileSettingsTile(
                icon: Icons.email_outlined,
                title: 'viktorkindrat@email.com',
                subtitle: 'Email address',
              ),
              const ProfileSettingsTile(
                icon: Icons.lock_outline,
                title: 'Password',
                subtitle: '••••••••••••',
              ),
              const SizedBox(height: 32),
              const KairoSectionHeader(title: 'General'),
              ProfileSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'App Theme',
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              const SizedBox(height: 32),
              KairoButton(
                text: 'Log Out',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/auth'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.primary,
          child: const Text(
            'VK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Viktor Kindrat',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Text(
          'SOFTWARE ENGINEER',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
