import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/features/profile/repositories/firestore_profile_mapper.dart';
import 'package:kairo/features/profile/utils/profile_auth_error_mapper.dart';

class FirestoreProfileRepository implements IProfileRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalUserStore _userStore;

  FirestoreProfileRepository({
    required LocalUserStore userStore,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _userStore = userStore;

  @override
  Future<LocalUser?> getProfile() async {
    final firebaseUser = _firebaseAuth.currentUser;
    final cachedUser = _userStore.readUser();

    if (firebaseUser == null) {
      return cachedUser;
    }

    try {
      final snapshot = await _userDocument(firebaseUser.uid).get();
      final profile = snapshot.exists
          ? mapFirestoreProfile(snapshot.data()!, firebaseUser, cachedUser)
          : mapFirebaseProfile(firebaseUser, cachedUser);

      await _userDocument(
        firebaseUser.uid,
      ).set(profileToFirestore(profile), SetOptions(merge: true));
      await _userStore.writeUserAndSession(profile);
      return profile;
    } on FirebaseException {
      return cachedUser ?? mapFirebaseProfile(firebaseUser, cachedUser);
    }
  }

  @override
  Future<ProfileUpdateResult> updateProfile({
    required String fullName,
    required String email,
    required String roleTitle,
    required String password,
  }) async {
    final currentUser = await getProfile();
    final firebaseUser = _firebaseAuth.currentUser;

    if (currentUser == null || firebaseUser == null) {
      throw const AuthException('No profile found to update.');
    }

    final normalizedEmail = normalizeEmail(email);
    final updatedUser = currentUser.copyWith(
      fullName: fullName.trim(),
      email: normalizedEmail,
      password: password,
      roleTitle: roleTitle.trim(),
    );
    final emailChanged = normalizeEmail(currentUser.email) != normalizedEmail;

    try {
      await _updateFirebaseUser(firebaseUser, updatedUser, emailChanged);

      if (emailChanged) {
        await _firebaseAuth.signOut();
        await _userStore.clearSessionEmail();
        await _userStore.clearUser();
        return ProfileUpdateResult(
          user: updatedUser,
          requiresEmailReconfirmation: true,
        );
      }

      await _userDocument(
        firebaseUser.uid,
      ).set(profileToFirestore(updatedUser), SetOptions(merge: true));
      await _userStore.writeUserAndSession(updatedUser);
      return ProfileUpdateResult(user: updatedUser);
    } on FirebaseAuthException catch (error) {
      throw mapProfileAuthException(error);
    }
  }

  @override
  Future<LocalUser> updateAvatar(String? avatarUrl) async {
    final currentUser = await getProfile();
    final firebaseUser = _firebaseAuth.currentUser;

    if (currentUser == null || firebaseUser == null) {
      throw const AuthException('No profile found to update.');
    }

    final updatedUser = currentUser.copyWith(
      avatarUrl: avatarUrl,
      clearAvatarUrl: avatarUrl == null,
    );

    await _userDocument(firebaseUser.uid).set({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _userStore.writeUser(updatedUser);
    return updatedUser;
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<void> _updateFirebaseUser(
    User firebaseUser,
    LocalUser updatedUser,
    bool emailChanged,
  ) async {
    if (updatedUser.fullName != (firebaseUser.displayName ?? '')) {
      await firebaseUser.updateDisplayName(updatedUser.fullName);
    }

    if (emailChanged) {
      await firebaseUser.verifyBeforeUpdateEmail(updatedUser.email);
      return;
    }

    await firebaseUser.reload();
  }
}
