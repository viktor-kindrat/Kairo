import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileAvatarStorage {
  const ProfileAvatarStorage._();

  static Future<String> savePickedAvatar(XFile pickedFile) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final avatarDirectory = Directory('${appDirectory.path}/profile_avatar');

    if (!avatarDirectory.existsSync()) {
      avatarDirectory.createSync(recursive: true);
    }

    final extension = _extractExtension(pickedFile.path);
    final storedFile = File(
      '${avatarDirectory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}'
      '$extension',
    );

    File(pickedFile.path).copySync(storedFile.path);

    return storedFile.path;
  }

  static Future<void> deleteAvatar(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) {
      return;
    }

    final avatarFile = File(avatarPath);

    if (avatarFile.existsSync()) {
      avatarFile.deleteSync();
    }
  }

  static String _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1) {
      return '.jpg';
    }

    return path.substring(dotIndex);
  }
}
