import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/email_password_fields.dart';
import 'package:kairo/features/auth/widgets/auth_action_section.dart';

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
  String? _formError;
  bool _isLoading = false;

  Future<void> _submit() async {
    final emailError = validateEmail(_emailController.text);
    final passwordError = validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
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

  void _clearErrorState() {
    if (_emailError == null && _passwordError == null && _formError == null) {
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
      _formError = null;
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
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.forgotPassword);
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: context.sp(24)),
        AuthActionSection(
          primaryButtonText: _isLoading ? 'Logging In...' : 'Log In',
          isPrimaryLoading: _isLoading,
          onPrimaryPressed: _submit,
          formError: _formError,
          footerMessage: 'New to Kairo?',
          footerActionText: 'Sign Up',
          onFooterTap: widget.onSwitchTab,
        ),
      ],
    );
  }
}
