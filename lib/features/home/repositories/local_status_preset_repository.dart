import 'package:kairo/core/constants.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStatusPresetRepository implements IStatusPresetRepository {
  final SharedPreferences _preferences;

  const LocalStatusPresetRepository(this._preferences);

  @override
  Future<void> clear() async {
    await _preferences.remove(statusPresetsKey);
  }

  @override
  Future<List<StatusPreset>> create(StatusPreset preset) async {
    final presets = await getAll();
    final updatedPresets = [...presets, preset];
    await _saveAll(updatedPresets);
    return updatedPresets;
  }

  @override
  Future<List<StatusPreset>> replaceAll(List<StatusPreset> presets) async {
    await _saveAll(presets);
    return presets;
  }

  @override
  Future<List<StatusPreset>> delete(String presetId) async {
    final presets = await getAll();
    final updatedPresets = presets
        .where((preset) => preset.id != presetId)
        .toList();

    if (updatedPresets.length == presets.length) {
      throw const StatusPresetException('Preset not found.');
    }

    await _saveAll(updatedPresets);
    return updatedPresets;
  }

  @override
  Future<List<StatusPreset>> getAll() async {
    final serializedPresets = _preferences.getStringList(statusPresetsKey);

    if (serializedPresets == null) {
      return const [];
    }

    return serializedPresets.map(StatusPreset.fromJson).toList();
  }

  @override
  Future<List<StatusPreset>> setActive(String presetId) async {
    final presets = await getAll();

    if (!presets.any((preset) => preset.id == presetId)) {
      throw const StatusPresetException('Preset not found.');
    }

    final updatedPresets = presets
        .map((preset) => preset.copyWith(isActive: preset.id == presetId))
        .toList();

    await _saveAll(updatedPresets);
    return updatedPresets;
  }

  @override
  Future<List<StatusPreset>> update(StatusPreset preset) async {
    final presets = await getAll();
    final presetIndex = presets.indexWhere(
      (existingPreset) => existingPreset.id == preset.id,
    );

    if (presetIndex == -1) {
      throw const StatusPresetException('Preset not found.');
    }

    final updatedPresets = [...presets];
    updatedPresets[presetIndex] = preset;
    await _saveAll(updatedPresets);
    return updatedPresets;
  }

  Future<void> _saveAll(List<StatusPreset> presets) async {
    final serializedPresets = presets.map((preset) => preset.toJson()).toList();
    await _preferences.setStringList(statusPresetsKey, serializedPresets);
  }
}
