import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/features/profile/cubit/slack_state.dart';
import 'package:kairo/features/profile/models/slack_connection_status.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';

class SlackCubit extends Cubit<SlackState> with WidgetsBindingObserver {
  final SlackConnectionRepository _repository;

  SlackCubit(SlackConnectionRepository repository)
      : _repository = repository,
        super(const SlackInitial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(loadStatus());
  }

  Future<void> loadStatus() async {
    emit(const SlackLoading());
    try {
      final status = await _repository.getStatus();
      emit(SlackLoaded(status));
    } catch (error) {
      emit(SlackError(error.toString()));
    }
  }

  Future<void> connect() async {
    final current = _currentStatus();
    if (current != null) emit(SlackBusy(current));
    try {
      await _repository.connect();
    } catch (error) {
      emit(SlackError(error.toString()));
    }
  }

  Future<void> disconnect() async {
    final current = _currentStatus();
    if (current != null) emit(SlackBusy(current));
    try {
      await _repository.disconnect();
      await loadStatus();
    } catch (error) {
      emit(SlackError(error.toString()));
    }
  }

  SlackConnectionStatus? _currentStatus() => switch (state) {
    SlackLoaded(:final status) => status,
    SlackBusy(:final status) => status,
    _ => null,
  };

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
