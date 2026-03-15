import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:open_mail/open_mail.dart';

class CheckInboxScreen extends StatefulWidget {
  final String email;

  const CheckInboxScreen({required this.email, super.key});

  @override
  State<CheckInboxScreen> createState() => _CheckInboxScreenState();
}

class _CheckInboxScreenState extends State<CheckInboxScreen> {
  int _secondsRemaining = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 20);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AuthHeader(
                backText: 'Login',
                onBackPressed: () => Navigator.pushNamed(context, '/auth'),
              ),
              const SizedBox(height: 40),

              SvgPicture.asset(
                'assets/illustrations/mail_check.svg',
                height: 240,
              ),
              const SizedBox(height: 32),

              // Тексти
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check your inbox.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'We\'ve sent a reset link to',
                  style: TextStyle(fontSize: 16, color: AppColors.textLight),
                ),
              ),
              const SizedBox(height: 16),

              // Email Pill (Плашка з імейлом)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05), // Легкий фон
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Інструкція (Степи)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildStep('1', 'Open the email from Kairo'),
                    const SizedBox(height: 20),
                    _buildStep('2', 'Tap "Reset my password"'),
                    const SizedBox(height: 20),
                    _buildStep('3', 'Create your new password'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Кнопка Open Email App
              KairoButton(
                text: 'Open Email App',
                icon: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () async {
                  // Намагаємось відкрити пошту за замовчуванням
                  final result = await OpenMail.openMailApp();

                  if (!context.mounted) return;

                  // Якщо не вийшло автоматично, але поштовики є (це часто буває на iOS,
                  // коли є Gmail, Outlook тощо) — показуємо свій міні-попап вибору
                  if (!result.didOpen && result.canOpen) {
                    final apps = await OpenMail.getMailApps();

                    if (!context.mounted || apps.isEmpty) return;

                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Open Mail App',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: apps.map((app) {
                                return ListTile(
                                  title: Text(
                                    app.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                  ),
                                  onTap: () {
                                    OpenMail.openSpecificMailApp(app.name);
                                    Navigator.pop(context); // Закриваємо попап
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  // Якщо поштовиків взагалі немає на телефоні
                  else if (!result.didOpen && !result.canOpen) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No email apps found on this device.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Таймер / Кнопка Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Didn\'t receive it? ',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                  if (_secondsRemaining > 0)
                    Text(
                      'Resend in ${_secondsRemaining}s',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _startTimer,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Resend',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Кнопка Back to Log In
              KairoButton(
                text: 'Back to Log In',
                isOutlined: true,
                onPressed: () => Navigator.popUntil(
                  context,
                  ModalRoute.withName('/auth'),
                ), // Заміни на свій шлях логіну
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Допоміжний віджет для кроків (1, 2, 3)
  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
