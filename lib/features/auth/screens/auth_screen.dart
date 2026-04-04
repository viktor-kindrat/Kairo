import 'package:flutter/material.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';
import 'package:kairo/core/widgets/kairo_tabs.dart';
import 'package:kairo/features/auth/widgets/auth_header.dart';
import 'package:kairo/features/auth/widgets/sign_in_form.dart';
import 'package:kairo/features/auth/widgets/sign_up_form.dart';

class AuthScreen extends StatefulWidget {
  final bool showSignUpInitially;

  const AuthScreen({super.key, this.showSignUpInitially = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = !widget.showSignUpInitially;
  }

  void _switchTab(bool toLogin) {
    if (isLogin == toLogin) {
      return;
    }

    setState(() {
      isLogin = toLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(24),
            vertical: context.sp(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(backButtonRemoved: true),
              SizedBox(height: context.sp(40)),
              KairoHeadline(
                headline: isLogin ? 'Start Focusing.' : 'Join Kairo.',
                subHeadline: isLogin
                    ? 'Welcome back to your workspace.'
                    : 'Create your account below',
              ),
              SizedBox(height: context.sp(32)),
              KairoTabs(
                tabs: const ['Log In', 'Sign Up'],
                selectedIndex: isLogin ? 0 : 1,
                onChanged: (index) => _switchTab(index == 0),
              ),
              const Divider(color: AppColors.border, height: 1, thickness: 1),
              SizedBox(height: context.sp(32)),
              if (isLogin)
                SignInForm(onSwitchTab: () => _switchTab(false))
              else
                SignUpForm(onSwitchTab: () => _switchTab(true)),
            ],
          ),
        ),
      ),
    );
  }
}
