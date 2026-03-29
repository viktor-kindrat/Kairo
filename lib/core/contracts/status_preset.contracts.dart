import 'package:kairo/core/models/status_preset.dart';

abstract class IStatusPresetRepository {
  Future<List<StatusPreset>> getAll();

  Future<List<StatusPreset>> create(StatusPreset preset);

  Future<List<StatusPreset>> update(StatusPreset preset);

  Future<List<StatusPreset>> delete(String presetId);

  Future<List<StatusPreset>> setActive(String presetId);

  Future<void> clear();
}
