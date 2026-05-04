import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/features/dashboard/cubit/analytics_state.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:kairo/features/mqtt/repositories/realtime_telemetry_history_repository.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  static const int _pageSize = 5;

  final RealtimeTelemetryHistoryRepository _historyRepository;
  final FirebaseDatabase _database;
  final Set<String> _loadedIds = {};
  List<RealtimeTelemetryHistoryItem> _items = const [];

  StreamSubscription<RealtimeTelemetryHistoryItem>? _latestItemSub;
  StreamSubscription<DatabaseEvent>? _summarySub;
  String? _oldestKey;

  late final VoidCallback _connectionListener;
  late final VoidCallback _topicListener;

  AnalyticsCubit({
    required RealtimeTelemetryHistoryRepository historyRepository,
    FirebaseDatabase? database,
  })  : _historyRepository = historyRepository,
        _database = database ?? createKairoRealtimeDatabase(),
        super(const AnalyticsState()) {
    _connectionListener = () => emit(
          state.copyWith(
            mqttConnectionState:
                MqttService.instance.connectionState.value,
          ),
        );
    _topicListener = () => emit(
          state.copyWith(
            subscribedTopic:
                MqttService.instance.subscribedTopic.value,
            clearTopic: MqttService.instance.subscribedTopic.value == null,
          ),
        );
    MqttService.instance.connectionState.addListener(_connectionListener);
    MqttService.instance.subscribedTopic.addListener(_topicListener);
  }

  Future<void> initialize() async {
    _startRealtimeUpdates();
    await _loadPage(reset: true);
    _startSummaryStream();
  }

  Future<void> loadNextPage() => _loadPage(reset: false);

  Future<void> refresh() => _loadPage(reset: true);

  void _startRealtimeUpdates() {
    unawaited(_latestItemSub?.cancel());
    _latestItemSub = _historyRepository.watchLatestEvent().listen(
      _prependItem,
      onError: (Object error) {
        if (error is RealtimeTelemetryHistoryAuthException) {
          emit(
            state.copyWith(
              requiresSignIn: true,
              hasMore: false,
              isInitialLoadDone: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              errorMessage: 'Could not listen for saved MQTT history updates.',
              isInitialLoadDone: true,
            ),
          );
        }
      },
    );
  }

  void _startSummaryStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    unawaited(_summarySub?.cancel());
    _summarySub = _database
        .ref('users/$uid/mqtt_analytics/summary')
        .onValue
        .listen((event) {
      final summary =
          MqttAnalyticsSummary.fromSnapshotValue(event.snapshot.value);
      emit(state.copyWith(summary: summary));
    });
  }

  Future<void> _loadPage({required bool reset}) async {
    if (state.isLoading || (!reset && !state.hasMore)) return;

    if (reset) {
      _resetState();
    } else {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final page = await _historyRepository.fetchPage(
        beforeKey: reset ? null : _oldestKey,
        limit: _pageSize,
      );
      _appendItems(page.items);
      emit(
        state.copyWith(
          items: _items,
          hasMore: page.hasMore,
          isLoading: false,
          isInitialLoadDone: true,
        ),
      );
    } on RealtimeTelemetryHistoryAuthException {
      emit(
        state.copyWith(
          requiresSignIn: true,
          hasMore: false,
          isLoading: false,
          isInitialLoadDone: true,
        ),
      );
    } catch (error) {
      debugPrint('AnalyticsCubit load error: $error');
      emit(
        state.copyWith(
          errorMessage: state.items.isEmpty
              ? 'Could not load saved MQTT history.'
              : 'Could not load more saved MQTT events.',
          isLoading: false,
          isInitialLoadDone: true,
        ),
      );
    }
  }

  void _prependItem(RealtimeTelemetryHistoryItem item) {
    if (!_loadedIds.add(item.id)) return;
    _items = List.unmodifiable([item, ..._items]);
    _oldestKey = _items.isEmpty ? null : _items.last.id;
    emit(
      state.copyWith(
        items: _items,
        requiresSignIn: false,
        clearError: true,
        isInitialLoadDone: true,
      ),
    );
  }

  void _appendItems(List<RealtimeTelemetryHistoryItem> nextItems) {
    final merged = [..._items];
    for (final item in nextItems) {
      if (_loadedIds.add(item.id)) merged.add(item);
    }
    _items = List.unmodifiable(merged);
    _oldestKey = _items.isEmpty ? null : _items.last.id;
  }

  void _resetState() {
    _loadedIds.clear();
    _oldestKey = null;
    _items = const [];
    emit(
      state.copyWith(
        items: const [],
        hasMore: true,
        isLoading: true,
        isInitialLoadDone: false,
        requiresSignIn: false,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    MqttService.instance.connectionState.removeListener(_connectionListener);
    MqttService.instance.subscribedTopic.removeListener(_topicListener);
    await _latestItemSub?.cancel();
    await _summarySub?.cancel();
    return super.close();
  }
}
