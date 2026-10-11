import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kairo/core/contexts/auth_context.dart';
import 'package:kairo/core/contexts/status_context.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/dashboard/screens/analytics_screen.dart';
import 'package:kairo/features/home/screens/home_screen.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:kairo/features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static int _lastSelectedIndex = 0;

  final MqttService _mqttService = MqttService.instance;
  late int _selectedIndex = _lastSelectedIndex;
  bool _isSeedingStatuses = false;
  String? _seededStatusUid;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeMqtt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureCurrentUserStatuses();
  }

  Future<void> _initializeMqtt() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      debugPrint('MQTT init skipped: no authenticated Firebase user.');
      return;
    }

    try {
      await _mqttService.connect();
      _mqttService.subscribe(MqttService.topicForUser(uid));
    } catch (error) {
      debugPrint('MQTT init error: $error');

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        context.showErrorSnackBar('Could not connect to MQTT broker.');
      });
    }
  }

  void _ensureCurrentUserStatuses() {
    final currentUser = context.auth.currentUser;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null ||
        uid == null ||
        _seededStatusUid == uid ||
        _isSeedingStatuses) {
      return;
    }

    _isSeedingStatuses = true;
    unawaited(_loadOrSeedStatuses(uid));
  }

  Future<void> _loadOrSeedStatuses(String uid) async {
    try {
      await context.statuses.loadOrSeedDefaults();
      _seededStatusUid = uid;
    } catch (error) {
      debugPrint('Could not seed status presets: $error');

      if (mounted) {
        context.showErrorSnackBar('Could not create cube statuses.');
      }
    } finally {
      _isSeedingStatuses = false;
    }
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _lastSelectedIndex = index;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
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
  }
}
