import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/dashboard/screens/analytics_screen.dart';
import 'package:kairo/features/home/screens/home_screen.dart';
import 'package:kairo/features/main/cubit/navigation_cubit.dart';
import 'package:kairo/features/profile/cubit/slack_cubit.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';
import 'package:kairo/features/profile/screens/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          SlackCubit(ctx.read<SlackConnectionRepository>())..loadStatus(),
      child: const _MainBody(),
    );
  }
}

class _MainBody extends StatelessWidget {
  const _MainBody();

  static const List<Widget> _screens = [
    HomeScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
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
    );
  }
}
