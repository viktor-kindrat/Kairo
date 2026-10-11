import 'package:kairo/features/profile/models/slack_connection_status.dart';

sealed class SlackState {
  const SlackState();
}

final class SlackInitial extends SlackState {
  const SlackInitial();
}

final class SlackLoading extends SlackState {
  const SlackLoading();
}

final class SlackLoaded extends SlackState {
  final SlackConnectionStatus status;

  const SlackLoaded(this.status);
}

final class SlackBusy extends SlackState {
  final SlackConnectionStatus status;

  const SlackBusy(this.status);
}

final class SlackError extends SlackState {
  final String message;

  const SlackError(this.message);
}
