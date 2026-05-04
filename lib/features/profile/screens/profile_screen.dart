import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';
import 'package:kairo/features/profile/cubit/slack_cubit.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';
import 'package:kairo/features/profile/utils/delete_account_flow.dart';
import 'package:kairo/features/profile/utils/profile_avatar_actions.dart';
import 'package:kairo/features/profile/widgets/background_glow.dart';
import 'package:kairo/features/profile/widgets/no_profile_view.dart';
import 'package:kairo/features/profile/widgets/profile_account_settings_sheet.dart';
import 'package:kairo/features/profile/widgets/profile_content.dart';
import 'package:kairo/features/profile/widgets/profile_password_settings_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SlackCubit(ctx.read<SlackConnectionRepository>())
        ..loadStatus(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const NoProfileView();
          }
          return _ProfileBody(user: authState.user);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final LocalUser user;

  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context) {
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
            onAvatarTap: () => _AvatarManager.show(context, user),
            onChangePassword: () => _openPasswordSettings(context, user),
            onDeleteAccount: () => _deleteAccount(context),
            onEditAccount: () => _openAccountSettings(context, user),
            onLogOut: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
    );
  }

  Future<void> _openAccountSettings(
    BuildContext context,
    LocalUser user,
  ) async {
    final authCubit = context.read<AuthCubit>();
    final updateResult = await showModalBottomSheet<ProfileUpdateResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => ProfileAccountSettingsSheet(
        user: user,
        onSave: ({
          required fullName,
          required email,
          required roleTitle,
        }) =>
            authCubit.updateProfile(
          fullName: fullName,
          email: email,
          roleTitle: roleTitle,
          password: user.password,
        ),
      ),
    );

    if (updateResult == null || !context.mounted) return;

    if (updateResult.requiresEmailReconfirmation) {
      context.showSuccessSnackBar(
        'Confirm your new email address, then sign in again to continue.',
      );
      return;
    }

    context.showSuccessSnackBar('Account details updated successfully.');
  }

  Future<void> _openPasswordSettings(
    BuildContext context,
    LocalUser user,
  ) async {
    final authCubit = context.read<AuthCubit>();
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => ProfilePasswordSettingsSheet(
        user: user,
        onSave: (password) => authCubit.updateProfile(
          fullName: user.fullName,
          email: user.email,
          roleTitle: user.roleTitle,
          password: password,
        ),
      ),
    );

    if (didSave != true || !context.mounted) return;
    context.showSuccessSnackBar('Password updated successfully.');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    await deleteProfileAccount(context: context);
  }
}

class _AvatarManager extends StatefulWidget {
  final LocalUser user;

  const _AvatarManager({required this.user});

  static Future<void> show(BuildContext context, LocalUser user) async {
    await showProfileAvatarActions(
      context: context,
      imagePicker: ImagePicker(),
      onBusyChanged: (_) {},
      user: user,
    );
  }

  @override
  State<_AvatarManager> createState() => _AvatarManagerState();
}

class _AvatarManagerState extends State<_AvatarManager> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isAvatarBusy = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isAvatarBusy ? null : () => _showAvatarActions(context),
      child: widget.user.avatarUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(widget.user.avatarUrl!),
            )
          : const CircleAvatar(child: Icon(Icons.person)),
    );
  }

  Future<void> _showAvatarActions(BuildContext context) async {
    await showProfileAvatarActions(
      context: context,
      imagePicker: _imagePicker,
      onBusyChanged: (busy) {
        if (mounted) setState(() => _isAvatarBusy = busy);
      },
      user: widget.user,
    );
  }
}
