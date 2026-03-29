import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';
import 'package:kairo/core/widgets/kairo_info_card.dart';
import 'package:kairo/features/auth/screens/check_inbox_screen.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  void _sendResetLink() async {
    final email = _emailController.text.trim();

    if (validateEmail(email) != null) {
      setState(() => _errorText = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    try {
      await context.auth.resetPassword(email);

      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => CheckInboxScreen(email: email),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorText = error.message;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              AuthHeader(
                onBackPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.auth),
              ),
              const SizedBox(height: 40),

              SvgPicture.asset('assets/illustrations/lock.svg', height: 240),
              const SizedBox(height: 32),

              const KairoHeadline(
                headline: 'Reset Password.',
                subHeadline:
                    'Enter your account email and we\'ll send you a secure '
                    'link to reset your password.',
              ),

              const SizedBox(height: 32),

              AppEmailInput(
                controller: _emailController,
                hintText: 'Email Address',
                errorText: _errorText,
                onChanged: (_) {
                  if (_errorText == null) {
                    return;
                  }

                  setState(() {
                    _errorText = null;
                  });
                },
              ),
              const SizedBox(height: 24),

              KairoButton(
                text: _isLoading ? 'Sending...' : 'Send Reset Link',
                isLoading: _isLoading,
                icon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendResetLink,
              ),

              const SizedBox(height: 40),
              const Divider(color: AppColors.border),
              const SizedBox(height: 32),

              AuthFooter(
                message: 'Remember your password? ',
                actionText: 'Log In',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),

              const KairoInfoCard(
                text:
                    'The reset link expires in 15 minutes for your security. '
                    'Check your spam folder if you don\'t see it.',
                boldText: '15 minutes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
