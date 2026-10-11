import 'package:flutter/material.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/utils/auth_validators.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/core/widgets/app_form_sheet_layout.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/profile/models/profile_account_save.dart';
import 'package:kairo/features/profile/utils/profile_account_field_errors.dart';
import 'package:kairo/features/profile/utils/profile_email_change_dialog.dart';
import 'package:kairo/features/profile/widgets/profile_account_settings_fields.dart';

class ProfileAccountSettingsSheet extends StatefulWidget {
  final LocalUser user;
  final ProfileAccountSave onSave;

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _roleTitleController = TextEditingController(text: widget.user.roleTitle);
  }

  Future<void> _save() async {
    final errors = validateProfileAccountFields(
      email: _emailController.text,
      fullName: _fullNameController.text,
      roleTitle: _roleTitleController.text,
    );

    setState(() {
      _fullNameError = errors.fullName;
      _emailError = errors.email;
      _roleTitleError = errors.roleTitle;
    });

    if (errors.hasErrors) {
      return;
    }

    final normalizedCurrentEmail = normalizeEmail(widget.user.email);
    final normalizedNextEmail = normalizeEmail(_emailController.text);

    if (normalizedCurrentEmail != normalizedNextEmail) {
      final shouldContinue = await confirmProfileEmailChange(context);

      if (!shouldContinue) {
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
      if (!mounted) {
        return;
      }

      context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearErrors() {
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _roleTitleError = null;
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
        ProfileAccountSettingsFields(
          emailController: _emailController,
          emailError: _emailError,
          fullNameController: _fullNameController,
          fullNameError: _fullNameError,
          onChanged: (_) => _clearErrors(),
          roleTitleController: _roleTitleController,
          roleTitleError: _roleTitleError,
        ),
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
