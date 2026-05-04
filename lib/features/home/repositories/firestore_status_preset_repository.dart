import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/utils/firestore_write_guard.dart';
import 'package:kairo/features/home/repositories/firestore_status_preset_remote_store.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';

class FirestoreStatusPresetRepository implements IStatusPresetRepository {
  final LocalStatusPresetRepository _localRepository;
  final FirestoreStatusPresetRemoteStore _remoteStore;

  FirestoreStatusPresetRepository({
    required LocalStatusPresetRepository localRepository,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _localRepository = localRepository,
       _remoteStore = FirestoreStatusPresetRemoteStore(
         firebaseAuth: firebaseAuth,
         firestore: firestore,
       );

  @override
  Future<void> clear() async {
    await ignoreFirestoreWriteFailure(_remoteStore.clear);
    await _localRepository.clear();
  }

  @override
  Future<List<StatusPreset>> create(StatusPreset preset) async {
    final presets = await _localRepository.create(preset);
    await ignoreFirestoreWriteFailure(() => _remoteStore.upsert(preset));
    return presets;
  }

  @override
  Future<List<StatusPreset>> replaceAll(List<StatusPreset> presets) async {
    await _remoteStore.replaceAll(presets);
    return _localRepository.replaceAll(presets);
  }

  @override
  Future<List<StatusPreset>> delete(String presetId) async {
    final presets = await _localRepository.delete(presetId);
    await ignoreFirestoreWriteFailure(() => _remoteStore.delete(presetId));
    return presets;
  }

  @override
  Future<List<StatusPreset>> getAll() async {
    try {
      final presets = await _remoteStore.getAll();

      if (presets == null) {
        return _localRepository.getAll();
      }

      if (presets.isEmpty) {
        await _localRepository.clear();
        return const [];
      }

      await _cachePresets(presets);
      return presets;
    } on FirebaseException {
      return _localRepository.getAll();
    }
  }

  @override
  Future<List<StatusPreset>> setActive(String presetId) async {
    final presets = await _localRepository.setActive(presetId);
    await ignoreFirestoreWriteFailure(() => _remoteStore.writeAll(presets));
    return presets;
  }

  @override
  Future<List<StatusPreset>> update(StatusPreset preset) async {
    final presets = await _localRepository.update(preset);
    await ignoreFirestoreWriteFailure(() => _remoteStore.upsert(preset));
    return presets;
  }

  Future<void> _cachePresets(List<StatusPreset> presets) async {
    await _localRepository.clear();

    for (final preset in presets) {
      await _localRepository.create(preset);
    }
  }
}
