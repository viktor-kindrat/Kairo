import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';
import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/verify_email_screen.dart';
import 'package:kairo/features/home/cubit/status_preset_cubit.dart';
import 'package:kairo/features/home/cubit/status_preset_state.dart';
import 'package:kairo/features/main/main_screen.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _syncedEmail;
  Future<void>? _syncFuture;

  Future<void> _ensureSyncedUser(User user) {
    final authCubit = context.read<AuthCubit>();
    final statusCubit = context.read<StatusPresetCubit>();
    final email = user.email;

    if (email == null) {
      _syncedEmail = null;
      authCubit.clearCurrentUser();
      return Future.value();
    }

    final currentState = authCubit.state;
    final alreadySynced = currentState is AuthAuthenticated &&
        currentState.user.email == email;

    if (_syncedEmail == email && alreadySynced) {
      return _syncFuture ?? Future.value();
    }

    _syncedEmail = email;
    _syncFuture = _syncAndConnect(authCubit, statusCubit, user);
    return _syncFuture!;
  }

  Future<void> _syncAndConnect(
    AuthCubit authCubit,
    StatusPresetCubit statusCubit,
    User user,
  ) async {
    await authCubit.refreshCurrentUser();
    if (!mounted) return;

    final uid = user.uid;
    unawaited(
      MqttService.instance.connect().then((_) {
        MqttService.instance.subscribe(MqttService.topicForUser(uid));
      }).catchError((_) {}),
    );

    if (statusCubit.state is StatusPresetInitial) {
      unawaited(statusCubit.loadOrSeedDefaults());
    }
  }

  void _clearSyncedUser() {
    _syncedEmail = null;
    _syncFuture = null;
    context.read<AuthCubit>().clearCurrentUser();
    MqttService.instance.disconnect();
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
          return VerifyEmailScreen(email: firebaseUser.email ?? '');
        }

        final syncFuture = _ensureSyncedUser(firebaseUser);

        return FutureBuilder<void>(
          future: syncFuture,
          builder: (context, syncSnapshot) {
            if (syncSnapshot.connectionState == ConnectionState.waiting &&
                context.read<AuthCubit>().state is! AuthAuthenticated) {
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
