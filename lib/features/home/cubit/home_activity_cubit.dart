import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/features/home/cubit/home_activity_state.dart';
import 'package:kairo/features/home/repositories/home_activity_repository.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

class HomeActivityCubit extends Cubit<HomeActivityState> {
  final HomeActivityRepository _repository;
  final Set<String> _loadedIds = {};

  StreamSubscription<RealtimeTelemetryHistoryItem>? _eventSubscription;
  DateTime _dayStart = _localDayStart(DateTime.now());

  HomeActivityCubit(HomeActivityRepository repository)
      : _repository = repository,
        super(const HomeActivityInitial());

  DateTime get dayStart => _dayStart;

  Future<void> start() => _loadCurrentDay();

  Future<void> refresh() => _loadCurrentDay();

  Future<void> onDayRollover(DateTime newDayStart) {
    _dayStart = newDayStart;
    return _loadCurrentDay();
  }

  Future<void> _loadCurrentDay() async {
    _dayStart = _localDayStart(DateTime.now());
    _loadedIds.clear();
    emit(const HomeActivityLoading());

    try {
      final events = await _repository.fetchTodayEvents(_dayStart);
      _loadedIds.addAll(events.todayEvents.map((e) => e.id));
      emit(
        HomeActivityLoaded(
          todayEvents: events.todayEvents,
          carryInEvent: events.carryInEvent,
          latestEvent: events.latestEvent,
          dayStart: _dayStart,
        ),
      );
      _subscribeToEvents();
    } on HomeActivityAuthException {
      emit(
        HomeActivityLoaded(
          todayEvents: const [],
          dayStart: _dayStart,
          requiresSignIn: true,
        ),
      );
    } catch (error) {
      debugPrint('HomeActivityCubit error: $error');
      emit(const HomeActivityError('Could not load today\'s cube activity.'));
    }
  }

  void _subscribeToEvents() {
    unawaited(_eventSubscription?.cancel());
    _eventSubscription = _repository
        .watchTodayEvents(_dayStart)
        .listen(_addEvent, onError: _handleStreamError);
  }

  void _addEvent(RealtimeTelemetryHistoryItem event) {
    if (!_loadedIds.add(event.id)) return;
    final current = state;
    if (current is! HomeActivityLoaded) return;

    final updated = [...current.todayEvents, event]
      ..sort((a, b) => a.entry.receivedAt.compareTo(b.entry.receivedAt));
    emit(
      HomeActivityLoaded(
        todayEvents: List.unmodifiable(updated),
        carryInEvent: current.carryInEvent,
        latestEvent: event,
        dayStart: current.dayStart,
      ),
    );
  }

  void _handleStreamError(Object error) {
    if (error is HomeActivityAuthException) {
      emit(
        HomeActivityLoaded(
          todayEvents: const [],
          dayStart: _dayStart,
          requiresSignIn: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _eventSubscription?.cancel();
    return super.close();
  }

  static DateTime _localDayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
