import 'package:flutter/foundation.dart';
import 'package:kairo/core/contracts/auth.contracts.dart';
import 'package:kairo/core/contracts/profile.contracts.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/features/auth/controllers/auth_profile_actions.dart';
import 'package:kairo/features/auth/controllers/auth_session_actions.dart';

class AuthController extends ChangeNotifier
    with AuthSessionActions, AuthProfileActions {
  @override
  final IAuthRepository authRepository;
  @override
  final IProfileRepository profileRepository;

  LocalUser? _currentUser;

  AuthController({
    required this.authRepository,
    required this.profileRepository,
  });

  @override
  LocalUser? get currentUser => _currentUser;

  @override
  void setCurrentUser(LocalUser? user, {bool notify = true}) {
    if (_currentUser == user) {
      return;
    }

    _currentUser = user;

    if (notify) {
      notifyListeners();
    }
  }
}
