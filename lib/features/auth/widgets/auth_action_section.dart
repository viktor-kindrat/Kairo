import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/inline_form_error_text.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/text_splitter.dart';
import 'package:kairo/features/auth/widgets/auth_footer.dart';
import 'package:kairo/features/auth/widgets/slack_auth_button.dart';

class AuthActionSection extends StatelessWidget {
  final String footerActionText;
  final String footerMessage;
  final VoidCallback onFooterTap;
  final VoidCallback onPrimaryPressed;
  final String primaryButtonText;
  final String? formError;
  final bool isPrimaryLoading;
  final VoidCallback? onSecondaryPressed;
  final String secondaryButtonText;
  final bool showSecondaryAction;

  const AuthActionSection({
    required this.footerActionText,
    required this.footerMessage,
    required this.onFooterTap,
    required this.onPrimaryPressed,
    required this.primaryButtonText,
    super.key,
    this.formError,
    this.isPrimaryLoading = false,
    this.onSecondaryPressed,
    this.secondaryButtonText = 'Continue with Slack',
    this.showSecondaryAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (formError != null) ...[
          InlineFormErrorText(message: formError!),
          SizedBox(height: context.sp(12)),
        ],
        KairoButton(
          text: primaryButtonText,
          isLoading: isPrimaryLoading,
          onPressed: onPrimaryPressed,
        ),
        if (showSecondaryAction) ...[
          SizedBox(height: context.sp(32)),
          const TextSplitter(content: 'or'),
          SizedBox(height: context.sp(32)),
          SlackAuthButton(
            text: secondaryButtonText,
            onPressed: onSecondaryPressed ?? () {},
          ),
        ],
        SizedBox(height: context.sp(40)),
        AuthFooter(
          message: footerMessage,
          actionText: footerActionText,
          onTap: onFooterTap,
        ),
      ],
    );
  }
}
