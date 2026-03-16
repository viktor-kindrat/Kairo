import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_section_header.dart';
import 'package:kairo/features/profile/widgets/profile_settings_tile.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

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
              _buildAvatar(context),
              SizedBox(height: context.sp(32)),
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
              SizedBox(height: context.sp(32)),
              const KairoSectionHeader(title: 'General'),
              ProfileSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'App Theme',
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              SizedBox(height: context.sp(32)),
              KairoButton(
                text: 'Log Out',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/auth'),
              ),
              SizedBox(height: context.sp(16)),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Delete Account',

                  style: TextStyle(color: Colors.red, fontSize: context.sp(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: context.sp(45),
          backgroundColor: AppColors.primary,
          child: Text(
            'VK',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: context.sp(16)),
        Text(
          'Viktor Kindrat',
          style: TextStyle(
            fontSize: context.sp(22),
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'SOFTWARE ENGINEER',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: context.sp(12),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
