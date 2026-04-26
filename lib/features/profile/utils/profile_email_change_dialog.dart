import 'package:flutter/material.dart';

Future<bool> confirmProfileEmailChange(BuildContext context) async {
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

  return shouldContinue == true;
}
