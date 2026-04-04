import 'package:flutter/material.dart';

extension SnackbarExtensions on BuildContext {
  void showErrorSnackBar(String message) {
    _showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccessSnackBar(String message) {
    _showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
