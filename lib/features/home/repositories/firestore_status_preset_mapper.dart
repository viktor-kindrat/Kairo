import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kairo/core/models/status_preset.dart';

StatusPreset mapStatusPresetDocument(
  QueryDocumentSnapshot<Map<String, dynamic>> document,
) {
  final data = document.data();

  return StatusPreset.fromMap({...data, 'id': data['id'] ?? document.id});
}

Map<String, Object?> statusPresetToFirestore(StatusPreset preset) {
  return {...preset.toMap(), 'updatedAt': FieldValue.serverTimestamp()};
}
