import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/utils/cube_telemetry_realtime_mapper.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';
import 'package:kairo/features/mqtt/utils/realtime_summary_builder.dart';

class RealtimeTelemetryRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _database;

  RealtimeTelemetryRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseDatabase? database,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _database = database ?? createKairoRealtimeDatabase();

  Future<void> recordEvent(CubeTelemetryEntry entry) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      debugPrint('RTDB MQTT event skipped: no authenticated user.');
      return;
    }

    try {
      final eventReference = _eventsReference(user.uid).push();
      final eventId = eventReference.key;

      if (eventId == null) {
        debugPrint('RTDB MQTT event skipped: generated event id is empty.');
        return;
      }

      await eventReference.set(entry.toRealtimeDatabaseMap());
      await _summaryReference(user.uid).runTransaction((currentData) {
        return Transaction.success(
          buildUpdatedMqttSummary(
            currentData: currentData,
            entry: entry,
            eventId: eventId,
          ),
        );
      }, applyLocally: false);
    } catch (error, stackTrace) {
      debugPrint('Realtime Database MQTT write failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  DatabaseReference _eventsReference(String uid) {
    return _database.ref('users/$uid/mqtt_events');
  }

  DatabaseReference _summaryReference(String uid) {
    return _database.ref('users/$uid/mqtt_analytics/summary');
  }
}
