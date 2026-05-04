import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/utils/uuid_v4.dart';
import 'package:kairo/features/home/cubit/status_preset_state.dart';
import 'package:kairo/features/home/models/cube_status_definition.dart';

class StatusPresetCubit extends Cubit<StatusPresetState> {
  final IStatusPresetRepository _repository;

  StatusPresetCubit(IStatusPresetRepository repository)
      : _repository = repository,
        super(const StatusPresetInitial());

  Future<void> loadOrSeedDefaults() async {
    emit(StatusPresetLoading(presets: state.presets));
    try {
      final stored = await _repository.getAll();
      final normalized = _normalizePresets(stored);
      final saved = await _repository.replaceAll(normalized);
      emit(StatusPresetLoaded(_sorted(saved)));
    } catch (error) {
      debugPrint('StatusPresetCubit: loadOrSeedDefaults error: $error');
      emit(
        StatusPresetError(
          message: 'Could not load statuses.',
          presets: state.presets,
        ),
      );
    }
  }

  Future<void> setActive(String presetId) async {
    try {
      final updated = await _repository.setActive(presetId);
      emit(StatusPresetLoaded(_sorted(updated)));
    } catch (_) {/* keep current state */}
  }

  Future<void> clear() async {
    await _repository.clear();
    emit(const StatusPresetInitial());
  }

  List<StatusPreset> _normalizePresets(List<StatusPreset> stored) {
    final byFace = {
      for (final p in stored)
        if (_knownFaces.contains(p.cubeFace)) p.cubeFace: p,
    };
    final activeFace = _activeFace(stored);

    return defaultCubeStatusDefinitions.map((def) {
      final existing = byFace[def.cubeFace];
      final id = isUuid(existing?.id ?? '') ? existing!.id : uuidV4();
      return def.toPreset(id: id, isActive: def.cubeFace == activeFace);
    }).toList(growable: false);
  }

  String _activeFace(List<StatusPreset> presets) {
    for (final p in presets) {
      if (p.isActive && _knownFaces.contains(p.cubeFace)) return p.cubeFace;
    }
    return defaultCubeStatusDefinitions.first.cubeFace;
  }

  Set<String> get _knownFaces =>
      defaultCubeStatusDefinitions.map((d) => d.cubeFace).toSet();

  List<StatusPreset> _sorted(List<StatusPreset> presets) =>
      [...presets]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}
