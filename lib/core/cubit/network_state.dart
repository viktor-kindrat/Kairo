class NetworkState {
  final bool isOffline;

  const NetworkState({required this.isOffline});

  const NetworkState.online() : isOffline = false;

  const NetworkState.offline() : isOffline = true;
}
