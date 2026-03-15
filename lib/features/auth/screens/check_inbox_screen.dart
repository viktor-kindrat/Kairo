import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kairo/core/constants.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_steps_list.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/check_inbox_actions.dart';
import 'package:kairo/features/auth/widgets/check_inbox_heading.dart';

class CheckInboxScreen extends StatefulWidget {
  final String email;

  const CheckInboxScreen({required this.email, super.key});

  @override
  State<CheckInboxScreen> createState() => _CheckInboxScreenState();
}

class _CheckInboxScreenState extends State<CheckInboxScreen> {
  int _secondsRemaining = RESEND_PASSWORD_TIMER;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = RESEND_PASSWORD_TIMER);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              AuthHeader(
                backText: 'Log In',
                onBackPressed: () => Navigator.pushNamed(context, '/auth'),
              ),
              const SizedBox(height: 40),
              Column(
                spacing: 32,
                children: [
                  CheckInboxHeading(email: widget.email),

                  const KairoStepsList(
                    steps: [
                      'Open the email from Kairo',
                      'Tap "Reset my password"',
                      'Create your new password',
                    ],
                  ),

                  CheckInboxActions(
                    secondsRemaining: _secondsRemaining,
                    startTimer: _startTimer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
