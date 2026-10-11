import 'package:kairo/core/models/profile_update_result.dart';

typedef ProfileAccountSave =
    Future<ProfileUpdateResult> Function({
      required String fullName,
      required String email,
      required String roleTitle,
    });
