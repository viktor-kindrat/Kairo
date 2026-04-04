import 'package:flutter/material.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:open_mail/open_mail.dart';

class MailUtils {
  static Future<void> openMailApp(BuildContext context) async {
    final result = await OpenMail.openMailApp();

    if (!context.mounted) return;

    if (!result.didOpen && result.canOpen) {
      final apps = await OpenMail.getMailApps();

      if (!context.mounted || apps.isEmpty) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Open Mail App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: apps
                  .map(
                    (app) => ListTile(
                      title: Text(
                        app.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        OpenMail.openSpecificMailApp(app.name);
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
    } else if (!result.didOpen && !result.canOpen) {
      context.showErrorSnackBar('No email apps found on this device.');
    }
  }
}
