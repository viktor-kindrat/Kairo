import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/profile/utils/profile_avatar_actions.dart';

class ProfileAvatarManager extends StatefulWidget {
  final LocalUser user;

  const ProfileAvatarManager({required this.user, super.key});

  static Future<void> show(BuildContext context, LocalUser user) async {
    await showProfileAvatarActions(
      context: context,
      imagePicker: ImagePicker(),
      onBusyChanged: (_) {},
      user: user,
    );
  }

  @override
  State<ProfileAvatarManager> createState() => _ProfileAvatarManagerState();
}

class _ProfileAvatarManagerState extends State<ProfileAvatarManager> {
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
