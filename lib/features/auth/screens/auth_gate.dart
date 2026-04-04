import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/verify_email_screen.dart';
import 'package:kairo/features/main/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _syncedEmail;
  Future<void>? _syncFuture;

  Future<void> _ensureSyncedUser(User user) {
    final authController = context.auth;
    final email = user.email;

    if (email == null) {
      _syncedEmail = null;
      authController.clearCurrentUser(notify: false);
      return Future.value();
    }

    if (_syncedEmail == email && authController.currentUser?.email == email) {
      return _syncFuture ?? Future.value();
    }

    _syncedEmail = email;
    _syncFuture = authController.refreshCurrentUser();
    return _syncFuture!;
  }

  void _clearSyncedUser() {
    _syncedEmail = null;
    _syncFuture = null;
    context.auth.clearCurrentUser(notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthGateLoader();
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          _clearSyncedUser();
          return const AuthScreen();
        }

        if (!firebaseUser.emailVerified) {
          _clearSyncedUser();
          return const VerifyEmailScreen();
        }

        final syncFuture = _ensureSyncedUser(firebaseUser);

        return FutureBuilder<void>(
          future: syncFuture,
          builder: (context, syncSnapshot) {
            if (syncSnapshot.connectionState == ConnectionState.waiting &&
                context.auth.currentUser == null) {
              return const _AuthGateLoader();
            }

            return const MainScreen();
          },
        );
      },
    );
  }
}

class _AuthGateLoader extends StatelessWidget {
  const _AuthGateLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
