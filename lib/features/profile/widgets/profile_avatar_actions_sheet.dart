import 'package:flutter/material.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';

class ProfileAvatarActionsSheet extends StatelessWidget {
  final bool hasAvatar;
  final VoidCallback onPickFromLibrary;
  final VoidCallback? onRemove;

  const ProfileAvatarActionsSheet({
    required this.hasAvatar,
    required this.onPickFromLibrary,
    super.key,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: 'Profile Picture',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choose from Library'),
          onTap: onPickFromLibrary,
        ),
        if (hasAvatar)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Remove Current Photo',
              style: TextStyle(color: Colors.red),
            ),
            onTap: onRemove,
          ),
      ],
    );
  }
}
