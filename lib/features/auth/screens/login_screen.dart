import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/widgets/kairo_button.dart';
import 'package:kairo/core/widgets/kairo_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхній ряд: Кнопка Назад та Логотип
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/app_icon.png',
                    height: 28,
                    width: 28,
                  ), // Твоє лого
                ],
              ),
              const SizedBox(height: 40),

              // Заголовки
              const Text(
                'Start Focusing.',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome back to your workspace.',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 32),

              // Кастомні Таби (Log In / Sign Up)
              Row(
                children: [
                  _buildTab('Log In', isActive: true),
                  const SizedBox(width: 24),
                  _buildTab('Sign Up', isActive: false),
                ],
              ),
              const Divider(color: AppColors.border, height: 1, thickness: 1),
              const SizedBox(height: 32),

              // Поля вводу
              const KairoInput(
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const KairoInput(
                hintText: 'Password',
                isPassword: true,
                suffixIcon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Головна кнопка (Чорна)
              KairoButton(
                text: 'Log In',
                onPressed: () {
                  // Перехід на дашборд (імітація входу)
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              const SizedBox(height: 32),

              // Розділювач "or"
              const Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Кнопка Slack (Контурна)
              KairoButton(
                text: 'Sign Up with Slack',
                isOutlined: true,
                // Можна юзати іконку з пакету flutter_svg або просто кастомну картинку
                icon: const Icon(
                  Icons.work,
                  color: Colors.blueAccent,
                ), // Заглушка для лого Slack
                onPressed: () {},
              ),
              const SizedBox(height: 40),

              // Create Account лінк
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to Kairo? ',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, {required bool isActive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        if (isActive) Container(height: 3, width: 48, color: AppColors.primary),
      ],
    );
  }
}
