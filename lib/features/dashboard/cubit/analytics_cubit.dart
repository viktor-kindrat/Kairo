import 'dart:async';

import 'package:firebase_database/firebase_database.dart' show FirebaseDatabase;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/features/dashboard/cubit/analytics_state.dart';
import 'package:kairo/features/dashboard/cubit/mqtt_summary_handler.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:kairo/features/mqtt/repositories/realtime_telemetry_history_repository.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  static const int _pageSize = 5;

  final RealtimeTelemetryHistoryRepository _historyRepository;
  final Set<String> _loadedIds = {};
  List<RealtimeTelemetryHistoryItem> _items = const [];
  String? _oldestKey;

  StreamSubscription<RealtimeTelemetryHistoryItem>? _latestItemSub;
  late final MqttSummaryHandler _mqttHandler;

  AnalyticsCubit({
    required RealtimeTelemetryHistoryRepository historyRepository,
    FirebaseDatabase? database,
  })  : _historyRepository = historyRepository,
        super(const AnalyticsState()) {
    _mqttHandler = MqttSummaryHandler(
      database: database ?? createKairoRealtimeDatabase(),
      onSummary: (s) => emit(state.copyWith(summary: s)),
      onConnection: (s) =>
          emit(state.copyWith(mqttConnectionState: s)),
      onTopic: (t) => emit(
        state.copyWith(
          subscribedTopic: t,
          clearTopic: t == null,
        ),
      ),
    );
  }

  Future<void> initialize() async {
    _startRealtimeUpdates();
    await _loadPage(reset: true);
    _mqttHandler.startSummaryStream();
  }

  Future<void> loadNextPage() => _loadPage(reset: false);

  Future<void> refresh() => _loadPage(reset: true);

  void _startRealtimeUpdates() {
    unawaited(_latestItemSub?.cancel());
    _latestItemSub = _historyRepository.watchLatestEvent().listen(
      _prependItem,
      onError: (Object error) {
        if (error is RealtimeTelemetryHistoryAuthException) {
          emit(state.copyWith(
            requiresSignIn: true,
            hasMore: false,
            isInitialLoadDone: true,
          ));
        } else {
          emit(state.copyWith(
            errorMessage:
                'Could not listen for saved MQTT history updates.',
            isInitialLoadDone: true,
          ));
        }
      },
    );
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
      final fresh = page.items.where((i) => _loadedIds.add(i.id));
      _items = List.unmodifiable([..._items, ...fresh]);
      _oldestKey = _items.isEmpty ? null : _items.last.id;
      emit(state.copyWith(
        items: _items,
        hasMore: page.hasMore,
        isLoading: false,
        isInitialLoadDone: true,
      ));
    } on RealtimeTelemetryHistoryAuthException {
      emit(state.copyWith(
        requiresSignIn: true,
        hasMore: false,
        isLoading: false,
        isInitialLoadDone: true,
      ));
    } catch (error) {
      debugPrint('AnalyticsCubit load error: $error');
      emit(state.copyWith(
        errorMessage: state.items.isEmpty
            ? 'Could not load saved MQTT history.'
            : 'Could not load more saved MQTT events.',
        isLoading: false,
        isInitialLoadDone: true,
      ));
    }
  }

  void _prependItem(RealtimeTelemetryHistoryItem item) {
    if (!_loadedIds.add(item.id)) return;
    _items = List.unmodifiable([item, ..._items]);
    _oldestKey = _items.isEmpty ? null : _items.last.id;
    emit(state.copyWith(
      items: _items,
      requiresSignIn: false,
      clearError: true,
      isInitialLoadDone: true,
    ));
  }

  void _resetState() {
    _loadedIds.clear();
    _oldestKey = null;
    _items = const [];
    emit(state.copyWith(
      items: const [],
      hasMore: true,
      isLoading: true,
      isInitialLoadDone: false,
      requiresSignIn: false,
      clearError: true,
    ));
  }

  @override
  Future<void> close() async {
    await _latestItemSub?.cancel();
    await _mqttHandler.dispose();
    return super.close();
  }
}
