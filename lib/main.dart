import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/app_routes.dart';
import 'package:kairo/core/cubit/network_cubit.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/local_user_store.dart';
import 'package:kairo/core/widgets/network_wrapper.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/repositories/firebase_auth_repository.dart';
import 'package:kairo/features/auth/screens/auth_gate.dart';
import 'package:kairo/features/auth/screens/auth_screen.dart';
import 'package:kairo/features/auth/screens/forgot_password_screen.dart';
import 'package:kairo/features/auth/screens/verify_email_screen.dart';
import 'package:kairo/features/home/cubit/status_preset_cubit.dart';
import 'package:kairo/features/home/repositories/firestore_status_preset_repository.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';
import 'package:kairo/features/main/cubit/navigation_cubit.dart';
import 'package:kairo/features/main/main_screen.dart';
import 'package:kairo/features/mqtt/repositories/realtime_telemetry_history_repository.dart';
import 'package:kairo/features/profile/repositories/account_deletion_repository.dart';
import 'package:kairo/features/profile/repositories/firestore_profile_repository.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';
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
  final slackRepository = SlackConnectionRepository();
  final telemetryHistoryRepository = RealtimeTelemetryHistoryRepository();
  final accountDeletionRepository = AccountDeletionRepository();

  runApp(
    KairoApp(
      authRepository: authRepository,
      profileRepository: profileRepository,
      statusRepository: statusRepository,
      slackRepository: slackRepository,
      telemetryHistoryRepository: telemetryHistoryRepository,
      accountDeletionRepository: accountDeletionRepository,
    ),
  );
}

class KairoApp extends StatelessWidget {
  final FirebaseAuthRepository authRepository;
  final FirestoreProfileRepository profileRepository;
  final FirestoreStatusPresetRepository statusRepository;
  final SlackConnectionRepository slackRepository;
  final RealtimeTelemetryHistoryRepository telemetryHistoryRepository;
  final AccountDeletionRepository accountDeletionRepository;

  const KairoApp({
    required this.authRepository,
    required this.profileRepository,
    required this.statusRepository,
    required this.slackRepository,
    required this.telemetryHistoryRepository,
    required this.accountDeletionRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: slackRepository),
        RepositoryProvider.value(value: telemetryHistoryRepository),
        RepositoryProvider.value(value: accountDeletionRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthCubit(
              authRepository: authRepository,
              profileRepository: profileRepository,
            ),
          ),
          BlocProvider(
            create: (_) => StatusPresetCubit(statusRepository),
          ),
          BlocProvider(
            create: (_) => NetworkCubit()..initialize(),
          ),
          BlocProvider(
            create: (_) => NavigationCubit(),
          ),
        ],
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
            AppRoutes.forgotPassword: (context) =>
                const ForgotPasswordScreen(),
            AppRoutes.verifyEmail: (context) => const VerifyEmailScreen(),
            AppRoutes.main: (context) => const MainScreen(),
          },
        ),
      ),
    );
  }
}
