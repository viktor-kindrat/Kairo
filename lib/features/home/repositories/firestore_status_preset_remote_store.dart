import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/repositories/firestore_status_preset_mapper.dart';

class FirestoreStatusPresetRemoteStore {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirestoreStatusPresetRemoteStore({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> clear() async {
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

  Future<void> delete(String presetId) async {
    await _presetsCollection?.doc(presetId).delete();
  }

  Future<List<StatusPreset>?> getAll() async {
    final collection = _presetsCollection;

    if (collection == null) {
      return null;
    }

    final snapshot = await collection.get();
    return snapshot.docs.map(mapStatusPresetDocument).toList();
  }

  Future<void> replaceAll(List<StatusPreset> presets) async {
    final userDocument = _userDocument;

    if (userDocument == null) {
      return;
    }

    final collection = userDocument.collection('status_presets');
    final snapshot = await collection.get();
    final batch = _firestore.batch();
    final presetIds = presets.map((preset) => preset.id).toSet();

    batch.set(userDocument, {
      'statusPresetsSeededAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    for (final document in snapshot.docs) {
      if (!presetIds.contains(document.id)) {
        batch.delete(document.reference);
      }
    }

    _setPresets(batch, collection, presets);
    await batch.commit();
  }

  Future<void> upsert(StatusPreset preset) async {
    await _presetsCollection
        ?.doc(preset.id)
        .set(statusPresetToFirestore(preset));
  }

  Future<void> writeAll(List<StatusPreset> presets) async {
    final collection = _presetsCollection;

    if (collection == null) {
      return;
    }

    final batch = _firestore.batch();
    _setPresets(batch, collection, presets);
    await batch.commit();
  }

  CollectionReference<Map<String, dynamic>>? get _presetsCollection {
    return _userDocument?.collection('status_presets');
  }

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    return _firestore.collection('users').doc(user.uid);
  }

  void _setPresets(
    WriteBatch batch,
    CollectionReference<Map<String, dynamic>> collection,
    List<StatusPreset> presets,
  ) {
    for (final preset in presets) {
      batch.set(collection.doc(preset.id), statusPresetToFirestore(preset));
    }
  }
}
