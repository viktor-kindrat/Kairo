import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/models/profile_update_result.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_email_input.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_input.dart';

class ProfileAccountSettingsSheet extends StatefulWidget {
  final LocalUser user;
  final Future<ProfileUpdateResult> Function({
    required String fullName,
    required String email,
    required String roleTitle,
  })
  onSave;

  const ProfileAccountSettingsSheet({
    required this.user,
    required this.onSave,
    super.key,
  });

  @override
  State<ProfileAccountSettingsSheet> createState() =>
      _ProfileAccountSettingsSheetState();
}

class _ProfileAccountSettingsSheetState
    extends State<ProfileAccountSettingsSheet> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleTitleController;

  String? _fullNameError;
  String? _emailError;
  String? _roleTitleError;
  String? _formError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _roleTitleController = TextEditingController(text: widget.user.roleTitle);
  }

  Future<void> _save() async {
    final fullNameError = validateFullName(_fullNameController.text);
    final emailError = validateEmail(_emailController.text);
    final roleTitleError = validateRoleTitle(_roleTitleController.text);

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _roleTitleError = roleTitleError;
      _formError = null;
    });

    if ([
      fullNameError,
      emailError,
      roleTitleError,
    ].any((error) => error != null)) {
      return;
    }

    final normalizedCurrentEmail = normalizeEmail(widget.user.email);
    final normalizedNextEmail = normalizeEmail(_emailController.text);

    if (normalizedCurrentEmail != normalizedNextEmail) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm new email'),
            content: const Text(
              'Changing your email will send a confirmation link to the new '
              'address and you will need to sign in again after confirming it.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (shouldContinue != true) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await widget.onSave(
        fullName: _fullNameController.text,
        email: _emailController.text,
        roleTitle: _roleTitleController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, result);
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
    if (_fullNameError == null &&
        _emailError == null &&
        _roleTitleError == null &&
        _formError == null) {
      return;
    }

    setState(() {
      _fullNameError = null;
      _emailError = null;
      _roleTitleError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _roleTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: 'Account Settings',
      description: 'Update your personal details, email, and role.',
      children: [
        KairoInput(
          controller: _fullNameController,
          hintText: 'Full Name',
          keyboardType: TextInputType.name,
          errorText: _fullNameError,
          onChanged: (_) => _clearErrors(),
        ),
        SizedBox(height: context.sp(16)),
        AppEmailInput(
          controller: _emailController,
          errorText: _emailError,
          onChanged: (_) => _clearErrors(),
        ),
        SizedBox(height: context.sp(16)),
        KairoInput(
          controller: _roleTitleController,
          hintText: 'Role Title',
          errorText: _roleTitleError,
          onChanged: (_) => _clearErrors(),
        ),
        if (_formError != null) ...[
          SizedBox(height: context.sp(16)),
          InlineFormErrorText(message: _formError!),
        ],
        SizedBox(height: context.sp(24)),
        KairoButton(
          text: _isSaving ? 'Saving...' : 'Save Changes',
          isLoading: _isSaving,
          onPressed: _save,
        ),
      ],
    );
  }
}
