import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/profile/utils/profile_avatar_actions.dart';
import 'package:kairo/features/profile/utils/profile_avatar_storage.dart';
import 'package:kairo/features/profile/widgets/background_glow.dart';
import 'package:kairo/features/profile/widgets/no_profile_view.dart';
import 'package:kairo/features/profile/widgets/profile_account_settings_sheet.dart';
import 'package:kairo/features/profile/widgets/profile_content.dart';
import 'package:kairo/features/profile/widgets/profile_password_settings_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _openAccountSettings(LocalUser user) async {
    final authController = context.auth;
    final updateResult = await showModalBottomSheet<ProfileUpdateResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return ProfileAccountSettingsSheet(
          user: user,
          onSave:
              ({required fullName, required email, required roleTitle}) async {
                return authController.updateProfile(
                  fullName: fullName,
                  email: email,
                  roleTitle: roleTitle,
                  password: user.password,
                );
              },
        );
      },
    );

    if (updateResult == null || !mounted) {
      return;
    }

    if (updateResult.requiresEmailReconfirmation) {
      context.showSuccessSnackBar(
        'Confirm your new email address, then sign in again to continue.',
      );
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

  Future<void> _logOut() => context.auth.signOut();

  Future<void> _deleteAccount() async {
    final authController = context.auth;
    final statusController = context.statuses;
    final avatarUrl = authController.currentUser?.avatarUrl;

    await statusController.clear();
    await ProfileAvatarStorage.deleteAvatar(avatarUrl);
    await authController.deleteAccount();
    await statusController.loadOrSeedDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.auth.currentUser;

    if (user == null) {
      return const NoProfileView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: Stack(
        children: [
          Positioned(
            left: -100,
            top: 80,
            child: BackgroundGlow(size: context.sp(220)),
          ),
          Positioned(
            right: -120,
            top: 120,
            child: BackgroundGlow(size: context.sp(240)),
          ),
          ProfileContent(
            user: user,
            onAvatarTap: () => showProfileAvatarActions(
              context: context,
              imagePicker: _imagePicker,
              user: user,
            ),
            onChangePassword: () => _openPasswordSettings(user),
            onDeleteAccount: _deleteAccount,
            onEditAccount: () => _openAccountSettings(user),
            onLogOut: _logOut,
          ),
        ],
      ),
    );
  }
}
