import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';

Future<void> submitGoogleSignIn({
  required BuildContext context,
  required bool Function() isBusy,
  required VoidCallback onComplete,
  required VoidCallback onStart,
}) async {
  if (isBusy()) {
    return;
  }

  onStart();

  try {
    await context.auth.signInWithGoogle();
  } on AuthException catch (error) {
    if (!context.mounted) {
      return;
    }

    context.showErrorSnackBar(error.message);
  } finally {
    if (context.mounted) {
      onComplete();
    }
  }
}
