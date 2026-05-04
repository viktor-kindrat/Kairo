import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/auth/cubit/auth_cubit.dart';
import 'package:kairo/features/auth/cubit/auth_state.dart';
import 'package:kairo/features/dashboard/screens/analytics_screen.dart';
import 'package:kairo/features/home/cubit/status_preset_cubit.dart';
import 'package:kairo/features/home/cubit/status_preset_state.dart';
import 'package:kairo/features/home/screens/home_screen.dart';
import 'package:kairo/features/main/cubit/navigation_cubit.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:kairo/features/profile/screens/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;

              final presetCubit = context.read<StatusPresetCubit>();
              unawaited(
                MqttService.instance.connect().then((_) {
                  MqttService.instance
                      .subscribe(MqttService.topicForUser(uid));
                }).catchError((_) {}),
              );

              if (presetCubit.state is StatusPresetInitial) {
                unawaited(presetCubit.loadOrSeedDefaults());
              }
            } else if (state is AuthUnauthenticated) {
              MqttService.instance.disconnect();
            }
          },
        ),
      ],
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, navState) {
          return Scaffold(
            body: IndexedStack(
              index: navState.selectedIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navState.selectedIndex,
              onTap: context.read<NavigationCubit>().selectTab,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textLight,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: context.sp(12),
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: context.sp(12),
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
