class SlackConnectionStatus {
  final bool connected;
  final String? slackUserId;
  final String? teamName;

  const SlackConnectionStatus({
    required this.connected,
    this.slackUserId,
    this.teamName,
  });

  factory SlackConnectionStatus.fromMap(Map<String, Object?> map) {
    return SlackConnectionStatus(
      connected: map['connected'] as bool? ?? false,
      slackUserId: map['slackUserId'] as String?,
      teamName: map['teamName'] as String?,
    );
  }

  String get subtitle {
    if (!connected) {
      return 'Sync MQTT statuses to your Slack profile';
    }

    if (teamName != null && teamName!.trim().isNotEmpty) {
      return 'Connected to $teamName';
    }

    return 'Slack connected';
  }
}
