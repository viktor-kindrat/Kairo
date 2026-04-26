import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/contracts/status_preset.contracts.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/core/utils/firestore_write_guard.dart';
import 'package:kairo/features/home/repositories/firestore_status_preset_mapper.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';

class FirestoreStatusPresetRepository implements IStatusPresetRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final LocalStatusPresetRepository _localRepository;

  FirestoreStatusPresetRepository({
    required LocalStatusPresetRepository localRepository,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localRepository = localRepository;

  @override
  Future<void> clear() async {
    await ignoreFirestoreWriteFailure(_clearRemote);
    await _localRepository.clear();
  }

  @override
  Future<List<StatusPreset>> create(StatusPreset preset) async {
    final presets = await _localRepository.create(preset);
    await ignoreFirestoreWriteFailure(() => _upsertRemote(preset));
    return presets;
  }

  @override
  Future<List<StatusPreset>> delete(String presetId) async {
    final presets = await _localRepository.delete(presetId);
    await ignoreFirestoreWriteFailure(() => _deleteRemote(presetId));
    return presets;
  }

  @override
  Future<List<StatusPreset>> getAll() async {
    final collection = _presetsCollection;

    if (collection == null) {
      return _localRepository.getAll();
    }

    try {
      final snapshot = await collection.get();

      if (snapshot.docs.isEmpty) {
        final cachedPresets = await _localRepository.getAll();
        await _writeRemotePresets(cachedPresets);
        return cachedPresets;
      }

      final presets = snapshot.docs.map(mapStatusPresetDocument).toList();
      await _cachePresets(presets);
      return presets;
    } on FirebaseException {
      return _localRepository.getAll();
    }
  }

  @override
  Future<List<StatusPreset>> setActive(String presetId) async {
    final presets = await _localRepository.setActive(presetId);
    await ignoreFirestoreWriteFailure(() => _writeRemotePresets(presets));
    return presets;
  }

  @override
  Future<List<StatusPreset>> update(StatusPreset preset) async {
    final presets = await _localRepository.update(preset);
    await ignoreFirestoreWriteFailure(() => _upsertRemote(preset));
    return presets;
  }

  CollectionReference<Map<String, dynamic>>? get _presetsCollection {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('status_presets');
  }

  Future<void> _cachePresets(List<StatusPreset> presets) async {
    await _localRepository.clear();

    for (final preset in presets) {
      await _localRepository.create(preset);
    }
  }

  Future<void> _clearRemote() async {
    final collection = _presetsCollection;

    if (collection == null) {
      return;
    }

    final snapshot = await collection.get();
    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }

  Future<void> _deleteRemote(String presetId) async {
    await _presetsCollection?.doc(presetId).delete();
  }

  Future<void> _upsertRemote(StatusPreset preset) async {
    await _presetsCollection
        ?.doc(preset.id)
        .set(statusPresetToFirestore(preset));
  }

  Future<void> _writeRemotePresets(List<StatusPreset> presets) async {
    final collection = _presetsCollection;

    if (collection == null) {
      return;
    }

    final batch = _firestore.batch();

    for (final preset in presets) {
      batch.set(collection.doc(preset.id), statusPresetToFirestore(preset));
    }

    await batch.commit();
  }
}
