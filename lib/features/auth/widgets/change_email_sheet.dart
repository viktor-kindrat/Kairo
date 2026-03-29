import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';

class ChangeEmailSheet extends StatefulWidget {
  final String initialEmail;
  final Future<void> Function(String email) onSubmit;

  const ChangeEmailSheet({
    required this.initialEmail,
    required this.onSubmit,
    super.key,
  });

  @override
  State<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<ChangeEmailSheet> {
  late final TextEditingController _emailController;
  String? _emailError;
  String? _formError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  Future<void> _submit() async {
    final emailError = validateEmail(_emailController.text);

    setState(() {
      _emailError = emailError;
      _formError = null;
    });

    if (emailError != null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSubmit(_emailController.text);

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
          _isSaving = false;
        });
      }
    }
  }

  void _clearErrors() {
    if (_emailError == null && _formError == null) {
      return;
    }

    setState(() {
      _emailError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: 'Change Email',
      description: 'Update the address where your verification code is sent.',
      children: [
        AppEmailInput(
          controller: _emailController,
          errorText: _emailError,
          onChanged: (_) => _clearErrors(),
        ),
        if (_formError != null) ...[
          SizedBox(height: context.sp(16)),
          InlineFormErrorText(message: _formError!),
        ],
        SizedBox(height: context.sp(24)),
        KairoButton(
          text: _isSaving ? 'Saving...' : 'Save New Email',
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
