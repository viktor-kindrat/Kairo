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
  required ValueChanged<bool> onBusyChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    builder: (sheetContext) {
      return ProfileAvatarActionsSheet(
        hasAvatar: user.avatarUrl != null,
        onPickFromLibrary: () async {
          Navigator.pop(sheetContext);
          await _pickAvatarImage(context, imagePicker, user, onBusyChanged);
        },
        onRemove: user.avatarUrl == null
            ? null
            : () async {
                Navigator.pop(sheetContext);
                await removeProfileAvatar(context, user, onBusyChanged);
              },
      );
    },
  );
}

Future<void> removeProfileAvatar(
  BuildContext context,
  LocalUser user,
  ValueChanged<bool> onBusyChanged,
) async {
  final authController = context.auth;

  onBusyChanged(true);

  try {
    await authController.updateAvatar(null);
    await ProfileAvatarStorage.deleteAvatar(user.avatarUrl);
  } catch (error) {
    if (context.mounted) {
      context.showErrorSnackBar(error.toString());
    }

    return;
  } finally {
    onBusyChanged(false);
  }

  if (!context.mounted) {
    return;
  }

  context.showSuccessSnackBar('Profile picture removed.');
}

Future<void> _pickAvatarImage(
  BuildContext context,
  ImagePicker imagePicker,
  LocalUser user,
  ValueChanged<bool> onBusyChanged,
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
  onBusyChanged(true);

  final String uploadedAvatarUrl;

  try {
    uploadedAvatarUrl = await ProfileAvatarStorage.uploadAvatar(pickedFile);
  } catch (error) {
    onBusyChanged(false);

    if (context.mounted) {
      context.showErrorSnackBar(error.toString());
    }

    return;
  }

  if (!context.mounted) {
    await ProfileAvatarStorage.deleteAvatar(uploadedAvatarUrl);
    onBusyChanged(false);
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
  } finally {
    onBusyChanged(false);
  }

  if (!context.mounted) {
    return;
  }

  context.showSuccessSnackBar('Profile picture updated.');
}
