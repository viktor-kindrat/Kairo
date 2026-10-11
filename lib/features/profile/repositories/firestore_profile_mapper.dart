import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/models/local_user.dart';

LocalUser mapFirestoreProfile(
  Map<String, dynamic> data,
  User user,
  LocalUser? cachedUser,
) {
  return LocalUser(
    fullName: data['fullName'] as String? ?? user.displayName ?? '',
    email: data['email'] as String? ?? user.email ?? '',
    password: cachedUser?.password ?? '',
    roleTitle: data['roleTitle'] as String? ?? defaultRoleTitle,
    avatarUrl: data['avatarUrl'] as String?,
  );
}

LocalUser mapFirebaseProfile(User user, LocalUser? cachedUser) {
  return LocalUser(
    fullName: user.displayName?.trim() ?? cachedUser?.fullName ?? '',
    email: user.email ?? cachedUser?.email ?? '',
    password: cachedUser?.password ?? '',
    roleTitle: cachedUser?.roleTitle ?? defaultRoleTitle,
    avatarUrl: cachedUser?.avatarUrl,
  );
}

Map<String, Object?> profileToFirestore(LocalUser user) {
  return {
    'fullName': user.fullName,
    'email': user.email,
    'roleTitle': user.roleTitle,
    'avatarUrl': user.avatarUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
