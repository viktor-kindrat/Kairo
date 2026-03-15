import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/email_validation.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';
import 'package:kairo/core/widgets/kairo_info_card.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/features/auth/screens/check_inbox_screen.dart';
import 'package:kairo/features/auth/services/auth_service.dart';
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

    if (email.isEmpty || !isEmailValid(email)) {
      setState(() => _errorText = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final success = await AuthService.sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => CheckInboxScreen(email: email),
        ),
      );
    } else {
      setState(() => _errorText = 'Something went wrong. Try again later.');
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              AuthHeader(
                onBackPressed: () => Navigator.pushNamed(context, '/auth'),
              ),
              const SizedBox(height: 40),

              SvgPicture.asset('assets/illustrations/lock.svg', height: 240),
              const SizedBox(height: 32),

              const KairoHeadline(
                headline: 'Reset Password.',
                subHeadline:
                    'Enter your account email and we\'ll send you a secure link to reset your password.',
              ),

              const SizedBox(height: 32),

              KairoInput(
                controller: _emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                errorText: _errorText,
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
                    'The reset link expires in 15 minutes for your security. Check your spam folder if you don\'t see it.',
                boldText: '15 minutes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
