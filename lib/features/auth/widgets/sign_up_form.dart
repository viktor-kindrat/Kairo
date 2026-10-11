import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/auth/utils/auth_google_submitter.dart';
import 'package:kairo/features/auth/widgets/auth_action_section.dart';
import 'package:kairo/features/auth/widgets/sign_up_fields.dart';

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

  void _clearErrors() {
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
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
        SignUpFields(
          confirmPasswordController: _confirmPasswordController,
          confirmPasswordError: _confirmPasswordError,
          emailController: _emailController,
          emailError: _emailError,
          fullNameController: _fullNameController,
          fullNameError: _fullNameError,
          onChanged: (_) => _clearErrors(),
          passwordController: _passwordController,
          passwordError: _passwordError,
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
          footerMessage: 'Already have an account? ',
          footerActionText: 'Log In',
          onFooterTap: widget.onSwitchTab,
        ),
      ],
    );
  }
}
