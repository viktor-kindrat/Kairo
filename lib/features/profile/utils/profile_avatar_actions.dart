import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/profile/utils/profile_avatar_storage.dart';
import 'package:kairo/features/profile/widgets/profile_avatar_actions_sheet.dart';

Future<void> showProfileAvatarActions({
  required BuildContext context,
  required ImagePicker imagePicker,
  required LocalUser user,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      return ProfileAvatarActionsSheet(
        hasAvatar: user.avatarUrl != null,
        onPickFromLibrary: () async {
          Navigator.pop(sheetContext);
          await _pickAvatarImage(context, imagePicker, user);
        },
        onRemove: user.avatarUrl == null
            ? null
            : () async {
                Navigator.pop(sheetContext);
                await removeProfileAvatar(context, user);
              },
      );
    },
  );
}

Future<void> removeProfileAvatar(BuildContext context, LocalUser user) async {
  final authController = context.auth;

  await authController.updateAvatar(null);
  await ProfileAvatarStorage.deleteAvatar(user.avatarUrl);

  if (!context.mounted) {
    return;
  }

  context.showSuccessSnackBar('Profile picture removed.');
}

Future<void> _pickAvatarImage(
  BuildContext context,
  ImagePicker imagePicker,
  LocalUser user,
) async {
  final pickedFile = await imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1200,
  );

  if (pickedFile == null) {
    return;
  }

  final previousAvatarUrl = user.avatarUrl;
  // Timestamped names avoid stale image cache; a later cleanup job can remove
  // rare orphan objects after app crashes or interrupted profile saves.
  final uploadedAvatarUrl = await ProfileAvatarStorage.uploadAvatar(pickedFile);

  if (!context.mounted) {
    await ProfileAvatarStorage.deleteAvatar(uploadedAvatarUrl);
    return;
  }

  try {
    await context.auth.updateAvatar(uploadedAvatarUrl);
    await ProfileAvatarStorage.deleteAvatar(previousAvatarUrl);
  } catch (error) {
    await ProfileAvatarStorage.deleteAvatar(uploadedAvatarUrl);

    if (!context.mounted) {
      return;
    }

    context.showErrorSnackBar(error.toString());
    return;
  }

  if (!context.mounted) {
    return;
  }

  context.showSuccessSnackBar('Profile picture updated.');
}
