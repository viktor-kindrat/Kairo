import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';
import 'package:kairo/core/widgets/kairo_tabs.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/sign_in_form.dart';
import 'package:kairo/features/auth/widgets/sign_up_form.dart';

class AuthScreen extends StatelessWidget {
  final bool showSignUpInitially;

  const AuthScreen({super.key, this.showSignUpInitially = false});

  @override
  Widget build(BuildContext context) {
    final isLogin = ValueNotifier<bool>(!showSignUpInitially);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(24),
            vertical: context.sp(16),
          ),
          child: ValueListenableBuilder<bool>(
            valueListenable: isLogin,
            builder: (context, login, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(backButtonRemoved: true),
                  SizedBox(height: context.sp(40)),
                  KairoHeadline(
                    headline: login ? 'Start Focusing.' : 'Join Kairo.',
                    subHeadline: login
                        ? 'Welcome back to your workspace.'
                        : 'Create your account below',
                  ),
                  SizedBox(height: context.sp(32)),
                  KairoTabs(
                    tabs: const ['Log In', 'Sign Up'],
                    selectedIndex: login ? 0 : 1,
                    onChanged: (index) => isLogin.value = index == 0,
                  ),
                  const Divider(
                    color: AppColors.border,
                    height: 1,
                    thickness: 1,
                  ),
                  SizedBox(height: context.sp(32)),
                  if (login)
                    SignInForm(onSwitchTab: () => isLogin.value = false)
                  else
                    SignUpForm(onSwitchTab: () => isLogin.value = true),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
