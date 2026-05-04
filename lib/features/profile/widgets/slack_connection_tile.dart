import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/profile/cubit/slack_cubit.dart';
import 'package:kairo/features/profile/cubit/slack_state.dart';
import 'package:kairo/features/profile/models/slack_connection_status.dart';
import 'package:kairo/features/profile/widgets/profile_account_row.dart';
import 'package:kairo/features/profile/widgets/slack_connection_action_button.dart';

class SlackConnectionTile extends StatelessWidget {
  const SlackConnectionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SlackCubit, SlackState>(
      listenWhen: (_, current) => current is SlackError,
      listener: (context, state) {
        if (state is SlackError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final status = _statusFrom(state);
        final isBusy = state is SlackLoading ||
            state is SlackBusy ||
            state is SlackInitial;

        return ProfileAccountRow(
          backgroundTint: const Color(0xFFF5EEFF),
          borderTint: const Color(0xFFE0CCFF),
          iconColor: const Color(0xFF6B4EFF),
          icon: Icons.link_rounded,
          title: status.connected ? 'Slack connected' : 'Connect Slack',
          subtitle: isBusy && state is! SlackBusy
              ? 'Checking Slack connection...'
              : status.subtitle,
          trailing: SlackConnectionActionButton(
            connected: status.connected,
            isBusy: isBusy,
            onPressed: () => _handleAction(context, status.connected),
          ),
        );
      },
    );
  }

  SlackConnectionStatus _statusFrom(SlackState state) => switch (state) {
    SlackLoaded(:final status) => status,
    SlackBusy(:final status) => status,
    _ => const SlackConnectionStatus(connected: false),
  };

  void _handleAction(BuildContext context, bool isConnected) {
    if (isConnected) {
      context.read<SlackCubit>().disconnect();
    } else {
      context.read<SlackCubit>().connect();
    }
  }
}
