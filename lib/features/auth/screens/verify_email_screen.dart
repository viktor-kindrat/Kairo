import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/resend_countdown_controller.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/auth/widgets/verify_email_content.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final ResendCountdownController _countdownController;

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _countdownController = ResendCountdownController(
      initialSeconds: resendPasswordTimer,
    )..start();
  }

  Future<void> _confirmEmailVerified() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      final isVerified = await context.auth.checkEmailVerified();

      if (!mounted) {
        return;
      }

      if (!isVerified) {
        context.showErrorSnackBar('Email is not verified yet.');
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isResending) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await context.auth.resendVerificationCode();
      _countdownController.start();

      if (!mounted) {
        return;
      }

      context.showSuccessSnackBar('A fresh verification email was sent.');
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _signOutToAuth() async {
    try {
      await context.auth.signOut();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingEmail =
        FirebaseAuth.instance.currentUser?.email ??
        context.auth.currentUser?.email ??
        'your email address';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: VerifyEmailContent(
          isResending: _isResending,
          isVerifying: _isVerifying,
          onBackPressed: _signOutToAuth,
          onConfirmPressed: _confirmEmailVerified,
          onResendPressed: _resendCode,
          pendingEmail: pendingEmail,
          resendCountdown: _countdownController,
        ),
      ),
    );
  }
}
