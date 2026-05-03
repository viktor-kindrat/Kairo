import 'package:flutter/material.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class SlackConnectionActionButton extends StatelessWidget {
  final bool connected;
  final bool isBusy;
  final VoidCallback? onPressed;

  const SlackConnectionActionButton({
    required this.connected,
    required this.isBusy,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: context.sp(20),
        height: context.sp(20),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return TextButton(
      onPressed: onPressed,
      child: Text(connected ? 'Disconnect' : 'Connect Slack'),
    );
  }
}
