import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/app_password_input.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';

class DeleteAccountReauthSheet extends StatefulWidget {
  final Future<void> Function(String password) onConfirm;

  const DeleteAccountReauthSheet({required this.onConfirm, super.key});

  @override
  State<DeleteAccountReauthSheet> createState() =>
      _DeleteAccountReauthSheetState();
}

class _DeleteAccountReauthSheetState extends State<DeleteAccountReauthSheet> {
  final TextEditingController _passwordController = TextEditingController();

  String? _formError;
  String? _passwordError;
  bool _isVerifying = false;

  Future<void> _confirm() async {
    final password = _passwordController.text;

    setState(() {
      _formError = null;
      _passwordError = password.isEmpty ? 'Please enter your password.' : null;
    });

    if (_passwordError != null) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await widget.onConfirm(password);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
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

  void _clearErrors() {
    if (_formError == null && _passwordError == null) {
      return;
    }

    setState(() {
      _formError = null;
      _passwordError = null;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: 'Confirm Deletion',
      description: 'Enter your password to continue deleting your account.',
      children: [
        AppPasswordInput(
          controller: _passwordController,
          hintText: 'Password',
          errorText: _passwordError,
          onChanged: (_) => _clearErrors(),
        ),
        if (_formError != null) ...[
          SizedBox(height: context.sp(16)),
          InlineFormErrorText(message: _formError!),
        ],
        SizedBox(height: context.sp(24)),
        KairoButton(
          text: _isVerifying ? 'Verifying...' : 'Continue Deleting',
          isLoading: _isVerifying,
          onPressed: _confirm,
        ),
      ],
    );
  }
}
