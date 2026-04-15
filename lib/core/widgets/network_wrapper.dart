import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({required this.child, super.key});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _initializeConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  Future<void> _initializeConnectivity() async {
    final results = await _connectivity.checkConnectivity();

    if (!mounted) {
      return;
    }

    _isOffline = _isOfflineResults(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOffline = _isOfflineResults(results);

    if (isOffline && !_isOffline && mounted) {
      context.showErrorSnackBar(
        'Немає підключення до Інтернету. Додаток працює в офлайн-режимі',
      );
    }

    _isOffline = isOffline;
  }

  bool _isOfflineResults(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
