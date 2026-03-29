import 'package:flutter/material.dart';
import 'package:kairo/features/auth/controllers/auth_controller.dart';

class AuthContext extends InheritedNotifier<AuthController> {
  const AuthContext({
    required AuthController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final authContext = context
        .dependOnInheritedWidgetOfExactType<AuthContext>();

    assert(authContext != null, 'AuthContext is missing in widget tree.');

    return authContext!.notifier!;
  }
}

extension AuthContextExtension on BuildContext {
  AuthController get auth => AuthContext.of(this);
}
