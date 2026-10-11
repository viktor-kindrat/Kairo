import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/cubit/network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const NetworkState.online());

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    emit(NetworkState(isOffline: _isOffline(results)));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      emit(NetworkState(isOffline: _isOffline(results)));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
