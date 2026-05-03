import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kairo/core/models/status_preset.dart';

class TelemetryStatusResolutionException implements Exception {
  final String message;

  const TelemetryStatusResolutionException(this.message);

  @override
  String toString() => message;
}

class FirestoreTelemetryStatusResolver {
  final FirebaseFirestore _firestore;

  FirestoreTelemetryStatusResolver({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<StatusPreset> resolve({
    required String uid,
    required String? orientation,
  }) async {
    final cubeFace = orientation?.trim();

    if (cubeFace == null || cubeFace.isEmpty) {
      throw const TelemetryStatusResolutionException(
        'MQTT event skipped: orientation is missing.',
      );
    }

    if (!_validCubeFaces.contains(cubeFace)) {
      throw TelemetryStatusResolutionException(
        'MQTT event skipped: orientation $cubeFace is invalid.',
      );
    }

    final snapshot = await _statusCollection(
      uid,
    ).where('cubeFace', isEqualTo: cubeFace).limit(2).get();

    if (snapshot.docs.isEmpty) {
      throw TelemetryStatusResolutionException(
        'MQTT event skipped: no status preset for orientation $cubeFace.',
      );
    }

    if (snapshot.docs.length > 1) {
      throw TelemetryStatusResolutionException(
        'MQTT event skipped: duplicate status presets for orientation '
        '$cubeFace.',
      );
    }

    final document = snapshot.docs.single;
    final preset = StatusPreset.fromMap({
      ...document.data(),
      'id': document.id,
    });

    if (!_isComplete(preset)) {
      throw TelemetryStatusResolutionException(
        'MQTT event skipped: status preset for orientation $cubeFace '
        'is incomplete.',
      );
    }

    return preset;
  }

  CollectionReference<Map<String, dynamic>> _statusCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('status_presets');
  }

  bool _isComplete(StatusPreset preset) {
    return preset.label.trim().isNotEmpty &&
        preset.slackEmojiCode.trim().isNotEmpty &&
        preset.cubeFace.trim().isNotEmpty;
  }

  Set<String> get _validCubeFaces {
    return const {'faceUp', 'faceDown', 'left', 'right', 'forward', 'backward'};
  }
}
