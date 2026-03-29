import 'package:flutter/foundation.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/utils/status_preset_icons.dart';

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

  Future<void> create({required String label, required String iconKey}) async {
    final preset = StatusPreset(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label.trim(),
      iconKey: iconKey,
      isActive: _presets.isEmpty,
    );

    _presets = await _statusPresetRepository.create(preset);
    notifyListeners();
  }

  Future<void> loadOrSeedDefaults() async {
    final storedPresets = await _statusPresetRepository.getAll();

    if (storedPresets.isNotEmpty) {
      _presets = storedPresets;
      notifyListeners();
      return;
    }

    List<StatusPreset> seededPresets = const [];

    for (final (index, option) in statusIconOptions.take(6).indexed) {
      seededPresets = await _statusPresetRepository.create(
        StatusPreset(
          id: 'default_${option.key}',
          label: option.label,
          iconKey: option.key,
          isActive: index == 0,
        ),
      );
    }

    _presets = seededPresets;
    notifyListeners();
  }

  Future<void> remove(String presetId) async {
    var updatedPresets = await _statusPresetRepository.delete(presetId);

    if (updatedPresets.isNotEmpty &&
        !updatedPresets.any((preset) => preset.isActive)) {
      updatedPresets = await _statusPresetRepository.setActive(
        updatedPresets.first.id,
      );
    }

    _presets = updatedPresets;
    notifyListeners();
  }

  Future<void> setActive(String presetId) async {
    _presets = await _statusPresetRepository.setActive(presetId);
    notifyListeners();
  }

  Future<void> update({
    required String presetId,
    required String label,
    required String iconKey,
  }) async {
    final existingPreset = _presets.firstWhere(
      (preset) => preset.id == presetId,
    );

    _presets = await _statusPresetRepository.update(
      existingPreset.copyWith(label: label.trim(), iconKey: iconKey),
    );
    notifyListeners();
  }
}
