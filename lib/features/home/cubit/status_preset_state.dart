import 'package:kairo/core/models/status_preset.dart';

sealed class StatusPresetState {
  const StatusPresetState();
}

final class StatusPresetInitial extends StatusPresetState {
  const StatusPresetInitial();
}

final class StatusPresetLoading extends StatusPresetState {
  final List<StatusPreset> presets;

  const StatusPresetLoading({this.presets = const []});
}

final class StatusPresetLoaded extends StatusPresetState {
  final List<StatusPreset> presets;

  const StatusPresetLoaded(this.presets);
}

final class StatusPresetError extends StatusPresetState {
  final String message;
  final List<StatusPreset> presets;

  const StatusPresetError({required this.message, this.presets = const []});
}

extension StatusPresetStateX on StatusPresetState {
  List<StatusPreset> get presets => switch (this) {
    StatusPresetInitial() => const [],
    StatusPresetLoading(:final presets) => presets,
    StatusPresetLoaded(:final presets) => presets,
    StatusPresetError(:final presets) => presets,
  };
}
