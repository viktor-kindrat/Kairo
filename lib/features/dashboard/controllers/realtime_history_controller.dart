import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:kairo/features/mqtt/repositories/realtime_telemetry_history_repository.dart';

class RealtimeHistoryController extends ChangeNotifier {
  static const int pageSize = 5;

  final RealtimeTelemetryHistoryRepository _repository;
  final Set<String> _loadedIds = <String>{};

  bool _hasMore = true;
  bool _isInitialLoadDone = false;
  bool _isLoading = false;
  bool _requiresSignIn = false;
  String? _errorMessage;
  String? _oldestKey;
  List<RealtimeTelemetryHistoryItem> _items = const [];
  StreamSubscription<RealtimeTelemetryHistoryItem>? _latestItemSubscription;

  RealtimeHistoryController({RealtimeTelemetryHistoryRepository? repository})
    : _repository = repository ?? RealtimeTelemetryHistoryRepository();

  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isInitialLoadDone => _isInitialLoadDone;
  bool get isLoading => _isLoading;
  List<RealtimeTelemetryHistoryItem> get items => _items;
  bool get requiresSignIn => _requiresSignIn;

  Future<void> loadInitialPage() => _loadPage(reset: true);

  Future<void> loadNextPage() => _loadPage(reset: false);

  Future<void> refresh() => _loadPage(reset: true);

  void startRealtimeUpdates() {
    unawaited(_latestItemSubscription?.cancel());
    _latestItemSubscription = _repository.watchLatestEvent().listen(
      _prependItem,
      onError: (Object error) {
        if (error is RealtimeTelemetryHistoryAuthException) {
          _requiresSignIn = true;
          _hasMore = false;
        } else {
          _errorMessage ??= 'Could not listen for saved MQTT history updates.';
        }

        _isInitialLoadDone = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    unawaited(_latestItemSubscription?.cancel());
    super.dispose();
  }

  Future<void> _loadPage({required bool reset}) async {
    if (_isLoading || (!reset && !_hasMore)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    if (reset) {
      _resetStateForRefresh();
    }

    notifyListeners();

    try {
      final page = await _repository.fetchPage(
        beforeKey: reset ? null : _oldestKey,
        limit: pageSize,
      );
      _appendItems(page.items);
      _hasMore = page.hasMore;
      _isInitialLoadDone = true;
    } on RealtimeTelemetryHistoryAuthException {
      _requiresSignIn = true;
      _hasMore = false;
      _isInitialLoadDone = true;
    } catch (_) {
      _errorMessage = _items.isEmpty
          ? 'Could not load saved MQTT history.'
          : 'Could not load more saved MQTT events.';
      _isInitialLoadDone = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _prependItem(RealtimeTelemetryHistoryItem item) {
    _requiresSignIn = false;
    _errorMessage = null;

    if (!_loadedIds.add(item.id)) {
      return;
    }

    _items = List.unmodifiable([item, ..._items]);
    _oldestKey = _items.isEmpty ? null : _items.last.id;
    _isInitialLoadDone = true;
    notifyListeners();
  }

  void _appendItems(List<RealtimeTelemetryHistoryItem> nextItems) {
    final merged = [..._items];

    for (final item in nextItems) {
      if (_loadedIds.add(item.id)) {
        merged.add(item);
      }
    }

    _items = List.unmodifiable(merged);
    _oldestKey = _items.isEmpty ? null : _items.last.id;
  }

  void _resetStateForRefresh() {
    _hasMore = true;
    _isInitialLoadDone = false;
    _items = const [];
    _loadedIds.clear();
    _oldestKey = null;
    _requiresSignIn = false;
  }
}
