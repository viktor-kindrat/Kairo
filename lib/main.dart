import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/core/widgets/network_wrapper.dart';
import 'package:kairo/features/auth/controllers/auth_controller.dart';
import 'package:kairo/features/auth/repositories/firebase_auth_repository.dart';
import 'package:kairo/features/auth/screens/auth_gate.dart';
import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/forgot_password_screen.dart';
import 'package:kairo/features/auth/screens/verify_email_screen.dart';
import 'package:kairo/features/home/controllers/status_controller.dart';
import 'package:kairo/features/home/repositories/firestore_status_preset_repository.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';
import 'package:kairo/features/main/main_screen.dart';
import 'package:kairo/features/profile/repositories/firestore_profile_repository.dart';
import 'package:kairo/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();
  final userStore = LocalUserStore(preferences);
  final authRepository = FirebaseAuthRepository(userStore: userStore);
  final localStatusRepository = LocalStatusPresetRepository(preferences);
  final profileRepository = FirestoreProfileRepository(userStore: userStore);
  final statusRepository = FirestoreStatusPresetRepository(
    localRepository: localStatusRepository,
  );
  final authController = AuthController(
    authRepository: authRepository,
    profileRepository: profileRepository,
  );
  final statusController = StatusController(
    statusPresetRepository: statusRepository,
  );

  await statusController.loadOrSeedDefaults();

  runApp(
    KairoApp(
      authController: authController,
      statusController: statusController,
    ),
  );
}

class KairoApp extends StatelessWidget {
  final AuthController authController;
  final StatusController statusController;

  const KairoApp({
    required this.authController,
    required this.statusController,
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
          home: const NetworkWrapper(child: AuthGate()),
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
