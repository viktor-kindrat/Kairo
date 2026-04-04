import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/profile/utils/profile_avatar_storage.dart';
import 'package:kairo/features/profile/widgets/profile_account_card.dart';
import 'package:kairo/features/profile/widgets/profile_account_settings_sheet.dart';
import 'package:kairo/features/profile/widgets/profile_avatar_actions_sheet.dart';
import 'package:kairo/features/profile/widgets/profile_edit_button.dart';
import 'package:kairo/features/profile/widgets/profile_hero.dart';
import 'package:kairo/features/profile/widgets/profile_password_settings_sheet.dart';
import 'package:kairo/features/profile/widgets/profile_settings_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _openAccountSettings(LocalUser user) async {
    final authController = context.auth;
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return ProfileAccountSettingsSheet(
          user: user,
          onSave:
              ({required fullName, required email, required roleTitle}) async {
                await authController.updateProfile(
                  fullName: fullName,
                  email: email,
                  roleTitle: roleTitle,
                  password: user.password,
                );
              },
        );
      },
    );

    if (didSave != true || !mounted) {
      return;
    }

    context.showSuccessSnackBar('Account details updated successfully.');
  }

  Future<void> _openPasswordSettings(LocalUser user) async {
    final authController = context.auth;
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return ProfilePasswordSettingsSheet(
          user: user,
          onSave: (password) async {
            await authController.updateProfile(
              fullName: user.fullName,
              email: user.email,
              roleTitle: user.roleTitle,
              password: password,
            );
          },
        );
      },
    );

    if (didSave != true || !mounted) {
      return;
    }

    context.showSuccessSnackBar('Password updated successfully.');
  }

  Future<void> _logOut() async {
    await context.auth.signOut();
  }

  Future<void> _deleteAccount() async {
    final authController = context.auth;
    final statusController = context.statuses;
    final avatarPath = authController.currentUser?.avatarPath;

    await authController.deleteAccount();
    await statusController.clear();
    await statusController.loadOrSeedDefaults();
    await ProfileAvatarStorage.deleteAvatar(avatarPath);
  }

  Future<void> _showAvatarActions(LocalUser user) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return ProfileAvatarActionsSheet(
          hasAvatar: user.avatarPath != null,
          onPickFromLibrary: () async {
            Navigator.pop(sheetContext);
            await _pickAvatarImage(user);
          },
          onRemove: user.avatarPath == null
              ? null
              : () async {
                  Navigator.pop(sheetContext);
                  await _removeAvatar(user);
                },
        );
      },
    );
  }

  Future<void> _pickAvatarImage(LocalUser user) async {
    final authController = context.auth;
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile == null) {
      return;
    }

    final previousAvatarPath = user.avatarPath;
    final storedAvatarPath = await ProfileAvatarStorage.savePickedAvatar(
      pickedFile,
    );

    try {
      await authController.updateAvatar(storedAvatarPath);
      await ProfileAvatarStorage.deleteAvatar(previousAvatarPath);
    } catch (error) {
      await ProfileAvatarStorage.deleteAvatar(storedAvatarPath);

      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.toString());
      return;
    }

    if (!mounted) {
      return;
    }

    context.showSuccessSnackBar('Profile picture updated.');
  }

  Future<void> _removeAvatar(LocalUser user) async {
    final authController = context.auth;

    await authController.updateAvatar(null);
    await ProfileAvatarStorage.deleteAvatar(user.avatarPath);

    if (!mounted) {
      return;
    }

    context.showSuccessSnackBar('Profile picture removed.');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'No active profile.',
            style: TextStyle(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: Stack(
        children: [
          Positioned(
            left: -100,
            top: 80,
            child: _BackgroundGlow(size: context.sp(220)),
          ),
          Positioned(
            right: -120,
            top: 120,
            child: _BackgroundGlow(size: context.sp(240)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ProfileEditButton(
                      onPressed: () => _openAccountSettings(user),
                    ),
                  ),
                  SizedBox(height: context.sp(12)),
                  ProfileHero(
                    user: user,
                    onAvatarTap: () => _showAvatarActions(user),
                  ),
                  SizedBox(height: context.sp(40)),
                  Text(
                    'ACCOUNT',
                    style: TextStyle(
                      color: const Color(0xFF9EA0AE),
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: context.sp(18)),
                  ProfileAccountCard(
                    user: user,
                    onEdit: () => _openAccountSettings(user),
                    onChangePassword: () => _openPasswordSettings(user),
                  ),
                  SizedBox(height: context.sp(28)),
                  const Text(
                    'GENERAL',
                    style: TextStyle(
                      color: Color(0xFF9EA0AE),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: context.sp(14)),
                  DecoratedBox(
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
                  ),
                  SizedBox(height: context.sp(28)),
                  KairoButton(text: 'Log Out', onPressed: _logOut),
                  SizedBox(height: context.sp(12)),
                  Center(
                    child: TextButton(
                      onPressed: _deleteAccount,
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;

  const _BackgroundGlow({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              AppColors.primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
