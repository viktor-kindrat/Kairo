import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';

import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/forgot_password_screen.dart';
import 'package:kairo/features/main/main_screen.dart';

void main() {
  runApp(const KairoApp());
}

class KairoApp extends StatelessWidget {
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorSchemeSeed: AppColors.primary,
      ),

      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
