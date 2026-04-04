import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/open_mail_client.dart';
import 'package:kairo/core/utils/resend_countdown_controller.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_info_card.dart';
import 'package:kairo/core/widgets/kairo_input.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/change_email_sheet.dart';
import 'package:kairo/features/auth/widgets/email_delivery_hero.dart';
import 'package:kairo/features/auth/widgets/resend_countdown_footer.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _codeController = TextEditingController();
  late final ResendCountdownController _countdownController;

  String? _codeError;
  String? _formError;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _countdownController = ResendCountdownController(
      initialSeconds: resendPasswordTimer,
    )..start();
  }

  Future<void> _verifyCode() async {
    final verificationCode = _codeController.text.trim();

    setState(() {
      _codeError = verificationCode.isEmpty
          ? 'Please enter the verification code.'
          : null;
      _formError = null;
    });

    if (_codeError != null) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await context.auth.verifyEmailCode(verificationCode);

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.main,
        (route) => false,
      );
    } on AuthException catch (error) {
      setState(() {
        _formError = error.message;
      });
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
      _formError = null;
    });

    try {
      await context.auth.resendVerificationCode();
      _countdownController.start();
      _codeController.clear();

      if (!mounted) {
        return;
      }

      context.showSuccessSnackBar('A fresh verification code was generated.');
    } on AuthException catch (error) {
      setState(() {
        _formError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _showChangeEmailSheet(String currentEmail) async {
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return ChangeEmailSheet(
          initialEmail: currentEmail,
          onSubmit: (email) async {
            await context.auth.updatePendingVerificationEmail(email);
          },
        );
      },
    );

    if (didSave != true || !mounted) {
      return;
    }

    _countdownController.start();
    _codeController.clear();
    context.showSuccessSnackBar('Verification email was updated and resent.');
  }

  Future<void> _cancelVerification() async {
    await context.auth.cancelPendingVerification();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.auth,
      (route) => false,
    );
  }

  void _clearErrors() {
    if (_codeError == null && _formError == null) {
      return;
    }

    setState(() {
      _codeError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingVerification = context.auth.pendingVerification;

    if (pendingVerification == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.auth,
          (route) => false,
        );
      });

      return const Scaffold(body: SizedBox.shrink());
    }

    final pendingEmail = pendingVerification.user.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                backText: 'Sign Up',
                onBackPressed: _cancelVerification,
              ),
              const SizedBox(height: 40),
              EmailDeliveryHero(
                email: pendingEmail,
                headline: 'Verify your email.',
                subHeadline: 'Enter the confirmation code we sent to',
              ),
              const SizedBox(height: 32),
              KairoInput(
                controller: _codeController,
                hintText: 'Verification code',
                keyboardType: TextInputType.number,
                errorText: _codeError,
                onChanged: (_) => _clearErrors(),
              ),
              const SizedBox(height: 24),
              if (_formError != null) ...[
                InlineFormErrorText(message: _formError!),
                const SizedBox(height: 12),
              ],
              KairoButton(
                text: _isVerifying ? 'Verifying...' : 'Verify Email',
                isLoading: _isVerifying,
                onPressed: _verifyCode,
              ),
              const SizedBox(height: 16),
              KairoButton(
                text: 'Open Email App',
                isOutlined: true,
                onPressed: () => MailUtils.openMailApp(context),
              ),
              const SizedBox(height: 32),
              KairoInfoCard(
                text:
                    'Local demo mode: the generated verification code is '
                    '${pendingVerification.code}.',
                boldText: pendingVerification.code,
              ),
              const SizedBox(height: 24),
              Center(
                child: ValueListenableBuilder<int>(
                  valueListenable: _countdownController,
                  builder: (context, secondsRemaining, child) {
                    return ResendCountdownFooter(
                      secondsRemaining: secondsRemaining,
                      isBusy: _isResending,
                      onTap: _resendCode,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => _showChangeEmailSheet(pendingEmail),
                  child: Text(
                    'Use a different email',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
