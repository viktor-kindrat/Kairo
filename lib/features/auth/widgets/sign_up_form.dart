import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/core/widgets/password_pair_fields.dart';
import 'package:kairo/features/auth/widgets/auth_action_section.dart';

class SignUpForm extends StatefulWidget {
  final VoidCallback onSwitchTab;

  const SignUpForm({required this.onSwitchTab, super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _formError;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _submit() async {
    final fullNameError = validateFullName(_fullNameController.text);
    final emailError = validateEmail(_emailController.text);
    final passwordError = validatePassword(_passwordController.text);
    final confirmPasswordError = validatePasswordConfirmation(
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
      _formError = null;
    });

    if ([
      fullNameError,
      emailError,
      passwordError,
      confirmPasswordError,
    ].any((error) => error != null)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.auth.signUp(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _formError = null;
      });
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
    if (_isLoading || _isGoogleLoading) {
      return;
    }

    setState(() {
      _formError = null;
      _isGoogleLoading = true;
    });

    try {
      await context.auth.signInWithGoogle();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _clearErrors() {
    if (_formError == null &&
        _fullNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      return;
    }

    setState(() {
      _fullNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: context.sp(16),
          children: [
            KairoInput(
              controller: _fullNameController,
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
              errorText: _fullNameError,
              onChanged: (_) => _clearErrors(),
            ),
            AppEmailInput(
              controller: _emailController,
              errorText: _emailError,
              onChanged: (_) => _clearErrors(),
            ),
            PasswordPairFields(
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              passwordError: _passwordError,
              confirmPasswordError: _confirmPasswordError,
              confirmPasswordHintText: 'Confirm password',
              onPasswordChanged: (_) => _clearErrors(),
              onConfirmPasswordChanged: (_) => _clearErrors(),
            ),
          ],
        ),
        SizedBox(height: context.sp(24)),
        AuthActionSection(
          primaryButtonText: _isLoading ? 'Signing Up...' : 'Sign Up',
          isPrimaryLoading: _isLoading,
          onPrimaryPressed: _submit,
          onSecondaryPressed: _submitGoogleSignIn,
          secondaryButtonText: _isGoogleLoading
              ? 'Connecting Google...'
              : 'Continue with Google',
          formError: _formError,
          footerMessage: 'Already have an account? ',
          footerActionText: 'Log In',
          onFooterTap: widget.onSwitchTab,
        ),
      ],
    );
  }
}
