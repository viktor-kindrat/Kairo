import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/email_password_fields.dart';
import 'package:kairo/features/auth/utils/auth_google_submitter.dart';
import 'package:kairo/features/auth/widgets/auth_action_section.dart';
import 'package:kairo/features/auth/widgets/forgot_password_link.dart';

class SignInForm extends StatefulWidget {
  final VoidCallback onSwitchTab;

  const SignInForm({required this.onSwitchTab, super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _submit() async {
    final emailError = validateEmail(_emailController.text);
    final passwordError = validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitGoogleSignIn() async {
    await submitGoogleSignIn(
      context: context,
      isBusy: () => _isLoading || _isGoogleLoading,
      onStart: () => setState(() => _isGoogleLoading = true),
      onComplete: () => setState(() => _isGoogleLoading = false),
    );
  }

  void _clearErrorState() {
    if (_emailError == null && _passwordError == null) {
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmailPasswordFields(
          emailController: _emailController,
          passwordController: _passwordController,
          emailError: _emailError,
          passwordError: _passwordError,
          onEmailChanged: (_) => _clearErrorState(),
          onPasswordChanged: (_) => _clearErrorState(),
        ),
        SizedBox(height: context.sp(16)),
        const ForgotPasswordLink(),
        SizedBox(height: context.sp(24)),
        AuthActionSection(
          primaryButtonText: _isLoading ? 'Logging In...' : 'Log In',
          isPrimaryLoading: _isLoading,
          onPrimaryPressed: _submit,
          onSecondaryPressed: _submitGoogleSignIn,
          secondaryButtonText: _isGoogleLoading
              ? 'Connecting Google...'
              : 'Continue with Google',
          footerMessage: 'New to Kairo?',
          footerActionText: 'Sign Up',
          onFooterTap: widget.onSwitchTab,
        ),
      ],
    );
  }
}
