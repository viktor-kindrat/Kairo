import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';

class ProfileAvatarStorage {
  const ProfileAvatarStorage._();

  static Future<void> deleteAvatar(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return;
    }

    if (!_isFirebaseUrl(avatarUrl)) {
      final localFile = File(avatarUrl);

      if (localFile.existsSync()) {
        localFile.deleteSync();
      }

      return;
    }

    try {
      await FirebaseStorage.instance.refFromURL(avatarUrl).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  static Future<String> uploadAvatar(XFile pickedFile) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const AuthException('Please log in to update your profile.');
    }

    final extension = _extractExtension(pickedFile.path);
    final reference = FirebaseStorage.instance.ref(
      'users/${user.uid}/avatar/avatar_'
      '${DateTime.now().millisecondsSinceEpoch}$extension',
    );

    await reference.putFile(
      File(pickedFile.path),
      SettableMetadata(contentType: _contentType(extension)),
    );

    return reference.getDownloadURL();
  }

  static String _contentType(String extension) {
    final normalizedExtension = extension.toLowerCase();

    if (normalizedExtension == '.png') {
      return 'image/png';
    }

    if (normalizedExtension == '.webp') {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  static String _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1) {
      return '.jpg';
    }

    return path.substring(dotIndex);
  }

  static bool _isFirebaseUrl(String avatarUrl) {
    final uri = Uri.tryParse(avatarUrl);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
