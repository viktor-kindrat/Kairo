import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/profile/widgets/profile_password_fields.dart';

class ProfilePasswordSettingsSheet extends StatefulWidget {
  final LocalUser user;
  final Future<void> Function(String password) onSave;

  const ProfilePasswordSettingsSheet({
    required this.user,
    required this.onSave,
    super.key,
  });

  @override
  State<ProfilePasswordSettingsSheet> createState() =>
      _ProfilePasswordSettingsSheetState();
}

class _ProfilePasswordSettingsSheetState
    extends State<ProfilePasswordSettingsSheet> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  String? _formError;
  bool _isSaving = false;

  Future<void> _save() async {
    final currentPasswordError = validateCurrentPassword(
      currentPassword: widget.user.password,
      enteredPassword: _currentPasswordController.text,
    );
    final newPasswordError = validatePassword(_newPasswordController.text);
    final confirmPasswordError = validatePasswordConfirmation(
      password: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() {
      _currentPasswordError = currentPasswordError;
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
      _formError = null;
    });

    if ([
      currentPasswordError,
      newPasswordError,
      confirmPasswordError,
    ].any((error) => error != null)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(_newPasswordController.text);

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
    if (_currentPasswordError == null &&
        _newPasswordError == null &&
        _confirmPasswordError == null &&
        _formError == null) {
      return;
    }

    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
      _formError = null;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSheetLayout(
      title: 'Change Password',
      description:
          'Confirm your current password, then choose a new secure one.',
      children: [
        ProfilePasswordFields(
          confirmPasswordController: _confirmPasswordController,
          currentPasswordController: _currentPasswordController,
          currentPasswordError: _currentPasswordError,
          confirmPasswordError: _confirmPasswordError,
          newPasswordController: _newPasswordController,
          newPasswordError: _newPasswordError,
          onChanged: (_) => _clearErrors(),
        ),
        if (_formError != null) ...[
          SizedBox(height: context.sp(16)),
          InlineFormErrorText(message: _formError!),
        ],
        SizedBox(height: context.sp(24)),
        KairoButton(
          text: _isSaving ? 'Updating...' : 'Update Password',
          isLoading: _isSaving,
          onPressed: _save,
        ),
      ],
    );
  }
}
