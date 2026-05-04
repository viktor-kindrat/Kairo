import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';
import 'package:kairo/features/home/cubit/status_preset_cubit.dart';
import 'package:kairo/features/profile/repositories/account_deletion_repository.dart';
import 'package:kairo/features/profile/utils/profile_avatar_storage.dart';
import 'package:kairo/features/profile/widgets/delete_account_reauth_sheet.dart';

Future<void> deleteProfileAccount({
  required BuildContext context,
}) async {
  final authCubit = context.read<AuthCubit>();
  final authState = authCubit.state;

  if (authState is! AuthAuthenticated) return;

  final deletionRepository = context.read<AccountDeletionRepository>();
  final avatarUrl = authState.user.avatarUrl;

  try {
    final didReauthenticate = await _reauthenticateForDeletion(
      context: context,
      authCubit: authCubit,
    );

    if (!didReauthenticate || !context.mounted) return;

    await _deleteAccountAndClearLocalState(
      context: context,
      deletionRepository: deletionRepository,
      authCubit: authCubit,
      avatarUrl: avatarUrl,
    );

    if (context.mounted) {
      context.showSuccessSnackBar('Account deleted successfully.');
    }
  } on AuthException catch (error) {
    if (context.mounted) context.showErrorSnackBar(error.message);
  } catch (error) {
    if (context.mounted) context.showErrorSnackBar(error.toString());
  }
}

Future<void> _deleteAccountAndClearLocalState({
  required BuildContext context,
  required AccountDeletionRepository deletionRepository,
  required AuthCubit authCubit,
  required String? avatarUrl,
}) async {
  final statusCubit = context.read<StatusPresetCubit>();
  await deletionRepository.deleteCurrentUserAccount();
  statusCubit.clear();
  await _deleteLegacyLocalAvatar(avatarUrl);
  try {
    await authCubit.signOut();
  } catch (_) {
    authCubit.clearCurrentUser();
  }
}

Future<void> _deleteLegacyLocalAvatar(String? avatarUrl) async {
  final uri = Uri.tryParse(avatarUrl ?? '');
  final isRemote =
      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  if (isRemote) return;
  await ProfileAvatarStorage.deleteAvatar(avatarUrl);
}

Future<bool> _reauthenticateForDeletion({
  required BuildContext context,
  required AuthCubit authCubit,
}) async {
  if (!authCubit.needsReauthenticationForSensitiveAction) return true;

  if (!authCubit.requiresPasswordForReauthentication) {
    await authCubit.reauthenticateForSensitiveAction();
    return true;
  }

  final didReauthenticate = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => DeleteAccountReauthSheet(
      onConfirm: (password) =>
          authCubit.reauthenticateForSensitiveAction(password: password),
    ),
  );

  return didReauthenticate == true;
}
