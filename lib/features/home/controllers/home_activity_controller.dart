import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/models/home_activity_status.dart';
import 'package:kairo/features/home/repositories/home_activity_repository.dart';
import 'package:kairo/features/home/utils/home_activity_calculator.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';

class HomeActivityController extends ChangeNotifier {
  final HomeActivityCalculator _calculator;
  final HomeActivityRepository _repository;
  final Set<String> _loadedIds = <String>{};

  DateTime _dayStart = _localDayStart(DateTime.now());
  String? _errorMessage;
  RealtimeTelemetryHistoryItem? _carryInEvent;
  StreamSubscription<RealtimeTelemetryHistoryItem>? _eventSubscription;
  RealtimeTelemetryHistoryItem? _latestEvent;
  Timer? _timer;
  bool _isLoading = true;
  bool _requiresSignIn = false;
  DateTime _now = DateTime.now();
  List<RealtimeTelemetryHistoryItem> _todayEvents = const [];

  HomeActivityController({
    HomeActivityCalculator calculator = const HomeActivityCalculator(),
    HomeActivityRepository? repository,
  }) : _calculator = calculator,
       _repository = repository ?? HomeActivityRepository();

  HomeActivitySnapshot snapshotFor(List<StatusPreset> presets) {
    return _calculator.calculate(
      carryInEvent: _carryInEvent,
      dayStart: _dayStart,
      errorMessage: _errorMessage,
      events: _todayEvents,
      isLoading: _isLoading,
      latestEvent: _latestEvent,
      now: _now,
      presets: presets,
      requiresSignIn: _requiresSignIn,
    );
  }

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    unawaited(_loadCurrentDay());
  }

  Future<void> refresh() => _loadCurrentDay();

  @override
  void dispose() {
    unawaited(_eventSubscription?.cancel());
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentDay() async {
    _dayStart = _localDayStart(DateTime.now());
    _isLoading = true;
    _requiresSignIn = false;
    _errorMessage = null;
    _loadedIds.clear();
    notifyListeners();

    try {
      final activityEvents = await _repository.fetchTodayEvents(_dayStart);
      _carryInEvent = activityEvents.carryInEvent;
      _latestEvent = activityEvents.latestEvent;
      _todayEvents = activityEvents.todayEvents;
      _loadedIds.addAll(_todayEvents.map((event) => event.id));
      _subscribeToTodayEvents();
    } on HomeActivityAuthException {
      _requiresSignIn = true;
      _todayEvents = const [];
      _carryInEvent = null;
      _latestEvent = null;
    } catch (_) {
      _errorMessage = 'Could not load today\'s cube activity.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToTodayEvents() {
    unawaited(_eventSubscription?.cancel());
    _eventSubscription = _repository
        .watchTodayEvents(_dayStart)
        .listen(
          _addEvent,
          onError: (Object error) {
            if (error is HomeActivityAuthException) {
              _requiresSignIn = true;
            } else {
              _errorMessage ??= 'Could not listen for cube activity updates.';
            }

            notifyListeners();
          },
        );
  }

  void _addEvent(RealtimeTelemetryHistoryItem event) {
    if (!_loadedIds.add(event.id)) {
      return;
    }

    final updatedEvents = [..._todayEvents, event]
      ..sort((a, b) => a.entry.receivedAt.compareTo(b.entry.receivedAt));
    _todayEvents = List.unmodifiable(updatedEvents);
    _latestEvent = event;
    _requiresSignIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _tick() {
    final nextNow = DateTime.now();
    final nextDayStart = _localDayStart(nextNow);
    _now = nextNow;

    if (nextDayStart != _dayStart) {
      unawaited(_loadCurrentDay());
      return;
    }

    notifyListeners();
  }

  static DateTime _localDayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
