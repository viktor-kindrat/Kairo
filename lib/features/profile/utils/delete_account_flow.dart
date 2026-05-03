import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/auth/controllers/auth_controller.dart';
import 'package:kairo/features/home/controllers/status_controller.dart';
import 'package:kairo/features/profile/repositories/account_deletion_repository.dart';
import 'package:kairo/features/profile/utils/profile_avatar_storage.dart';
import 'package:kairo/features/profile/widgets/delete_account_reauth_sheet.dart';

Future<void> deleteProfileAccount({
  required BuildContext context,
  required AuthController authController,
  required StatusController statusController,
  AccountDeletionRepository? accountDeletionRepository,
}) async {
  if (authController.currentUser == null) {
    return;
  }

  final deletionRepository =
      accountDeletionRepository ?? AccountDeletionRepository();
  final avatarUrl = authController.currentUser?.avatarUrl;

  try {
    final didReauthenticate = await _reauthenticateForDeletion(
      context: context,
      authController: authController,
    );

    if (!didReauthenticate) {
      return;
    }

    await _deleteAccountAndClearLocalState(
      accountDeletionRepository: deletionRepository,
      authController: authController,
      avatarUrl: avatarUrl,
      statusController: statusController,
    );

    if (context.mounted) {
      context.showSuccessSnackBar('Account deleted successfully.');
    }
  } on AuthException catch (error) {
    if (context.mounted) {
      context.showErrorSnackBar(error.message);
    }
  } catch (error) {
    if (context.mounted) {
      context.showErrorSnackBar(error.toString());
    }
  }
}

Future<void> _deleteAccountAndClearLocalState({
  required AccountDeletionRepository accountDeletionRepository,
  required AuthController authController,
  required StatusController statusController,
  required String? avatarUrl,
}) async {
  await accountDeletionRepository.deleteCurrentUserAccount();
  await statusController.clear();
  await _deleteLegacyLocalAvatar(avatarUrl);
  await _clearAuthSession(authController);
}

Future<void> _deleteLegacyLocalAvatar(String? avatarUrl) async {
  final uri = Uri.tryParse(avatarUrl ?? '');
  final isRemoteAvatar =
      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

  if (isRemoteAvatar) {
    return;
  }

  await ProfileAvatarStorage.deleteAvatar(avatarUrl);
}

Future<void> _clearAuthSession(AuthController authController) async {
  try {
    await authController.signOut();
  } catch (_) {
    authController.clearCurrentUser();
  }
}

Future<bool> _reauthenticateForDeletion({
  required BuildContext context,
  required AuthController authController,
}) async {
  if (!authController.needsReauthenticationForSensitiveAction) {
    return true;
  }

  if (!authController.requiresPasswordForReauthentication) {
    await authController.reauthenticateForSensitiveAction();
    return true;
  }

  final didReauthenticate = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      return DeleteAccountReauthSheet(
        onConfirm: (password) {
          return authController.reauthenticateForSensitiveAction(
            password: password,
          );
        },
      );
    },
  );

  return didReauthenticate == true;
}
