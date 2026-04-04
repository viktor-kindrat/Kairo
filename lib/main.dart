import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/features/auth/controllers/auth_controller.dart';
import 'package:kairo/features/auth/repositories/local_auth_repository.dart';
import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/forgot_password_screen.dart';
import 'package:kairo/features/auth/screens/verify_email_screen.dart';
import 'package:kairo/features/home/controllers/status_controller.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';
import 'package:kairo/features/main/main_screen.dart';
import 'package:kairo/features/profile/repositories/local_profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final userStore = LocalUserStore(preferences);
  final authRepository = LocalAuthRepository(preferences, userStore: userStore);
  final profileRepository = LocalProfileRepository(
    preferences,
    userStore: userStore,
  );
  final statusRepository = LocalStatusPresetRepository(preferences);
  final authController = AuthController(
    authRepository: authRepository,
    profileRepository: profileRepository,
  );
  final statusController = StatusController(
    statusPresetRepository: statusRepository,
  );

  await authController.initialize();
  await statusController.loadOrSeedDefaults();

  runApp(
    KairoApp(
      authController: authController,
      statusController: statusController,
      initialRoute: authController.isAuthenticated
          ? AppRoutes.main
          : authController.hasPendingVerification
          ? AppRoutes.verifyEmail
          : AppRoutes.auth,
    ),
  );
}

class KairoApp extends StatelessWidget {
  final AuthController authController;
  final StatusController statusController;
  final String initialRoute;

  const KairoApp({
    required this.authController,
    required this.statusController,
    required this.initialRoute,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AuthContext(
      controller: authController,
      child: StatusContext(
        controller: statusController,
        child: MaterialApp(
          title: 'Kairo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
            colorSchemeSeed: AppColors.primary,
          ),
          initialRoute: initialRoute,
          routes: {
            AppRoutes.auth: (context) => const AuthScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
            AppRoutes.main: (context) => const MainScreen(),
          },
        ),
      ),
    );
  }
}
