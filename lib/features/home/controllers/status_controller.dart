import 'package:flutter/foundation.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/exceptions/app_exceptions.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/utils/uuid_v4.dart';
import 'package:kairo/features/home/models/cube_status_definition.dart';

class StatusController extends ChangeNotifier {
  final IStatusPresetRepository _statusPresetRepository;

  List<StatusPreset> _presets = const [];

  StatusController({required IStatusPresetRepository statusPresetRepository})
    : _statusPresetRepository = statusPresetRepository;

  List<StatusPreset> get presets => List.unmodifiable(_presets);

  Future<void> clear() async {
    await _statusPresetRepository.clear();
    _presets = const [];
    notifyListeners();
  }

  Future<void> create({
    required String label,
    required String slackEmojiCode,
  }) async {
    throw const StatusPresetException('Custom statuses are not supported yet.');
  }

  Future<void> loadOrSeedDefaults() async {
    final storedPresets = await _statusPresetRepository.getAll();
    final normalizedPresets = _normalizePresets(storedPresets);

    _presets = await _statusPresetRepository.replaceAll(normalizedPresets);
    _presets = _sortedPresets(_presets);
    notifyListeners();
  }

  Future<void> remove(String presetId) async {
    throw const StatusPresetException('Cube face statuses cannot be removed.');
  }

  Future<void> setActive(String presetId) async {
    _presets = await _statusPresetRepository.setActive(presetId);
    notifyListeners();
  }

  Future<void> update({
    required String presetId,
    required String label,
    required String slackEmojiCode,
  }) async {
    throw const StatusPresetException('Custom statuses are not supported yet.');
  }

  List<StatusPreset> _normalizePresets(List<StatusPreset> storedPresets) {
    final storedByFace = {
      for (final preset in storedPresets)
        if (_knownCubeFaces.contains(preset.cubeFace)) preset.cubeFace: preset,
    };
    final activeFace = _activeCubeFace(storedPresets);

    return defaultCubeStatusDefinitions
        .map((definition) {
          final storedPreset = storedByFace[definition.cubeFace];
          final storedId = storedPreset?.id ?? '';
          final statusId = isUuid(storedId) ? storedId : uuidV4();

          return definition.toPreset(
            id: statusId,
            isActive: definition.cubeFace == activeFace,
          );
        })
        .toList(growable: false);
  }

  String _activeCubeFace(List<StatusPreset> presets) {
    for (final preset in presets) {
      if (preset.isActive && _knownCubeFaces.contains(preset.cubeFace)) {
        return preset.cubeFace;
      }
    }

    return defaultCubeStatusDefinitions.first.cubeFace;
  }

  Set<String> get _knownCubeFaces {
    return defaultCubeStatusDefinitions
        .map((definition) => definition.cubeFace)
        .toSet();
  }

  List<StatusPreset> _sortedPresets(List<StatusPreset> presets) {
    return [...presets]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
