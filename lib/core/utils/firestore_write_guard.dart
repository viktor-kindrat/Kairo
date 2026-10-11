import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> ignoreFirestoreWriteFailure(Future<void> Function() write) async {
  try {
    await write();
  } on FirebaseException catch (error, stackTrace) {
    debugPrint('Firestore write failed: ${error.message ?? error.code}');
    debugPrintStack(stackTrace: stackTrace);
    return;
  }
}
