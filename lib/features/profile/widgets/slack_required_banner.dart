import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';
import 'package:kairo/features/profile/cubit/slack_cubit.dart';
import 'package:kairo/features/profile/cubit/slack_state.dart';

class SlackRequiredBanner extends StatelessWidget {
  const SlackRequiredBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlackCubit, SlackState>(
      builder: (context, state) {
        final isConnected = switch (state) {
          SlackLoaded(:final status) => status.connected,
          SlackBusy(:final status) => status.connected,
          _ => true,
        };

        if (isConnected) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.sp(16)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            border: Border.all(color: const Color(0xFFFED7AA)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFC2410C),
                size: context.sp(22),
              ),
              SizedBox(width: context.sp(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slack integration required',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: context.sp(4)),
                    Text(
                      'Cube data will not be read or saved until Slack is '
                      'connected in your profile.',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: context.sp(13),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
