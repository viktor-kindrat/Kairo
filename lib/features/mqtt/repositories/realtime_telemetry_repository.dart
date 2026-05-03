import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:kairo/features/mqtt/repositories/firestore_telemetry_status_resolver.dart';
import 'package:kairo/features/mqtt/utils/cube_telemetry_realtime_mapper.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';
import 'package:kairo/features/mqtt/utils/realtime_summary_builder.dart';

class RealtimeTelemetryRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFunctions _functions;
  final FirebaseDatabase _database;
  final FirestoreTelemetryStatusResolver _statusResolver;

  RealtimeTelemetryRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFunctions? functions,
    FirebaseDatabase? database,
    FirestoreTelemetryStatusResolver? statusResolver,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _database = database ?? createKairoRealtimeDatabase(),
       _statusResolver = statusResolver ?? FirestoreTelemetryStatusResolver();

  Future<void> recordEvent(CubeTelemetryEntry entry) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      debugPrint('RTDB MQTT event skipped: no authenticated user.');
      return;
    }

    try {
      final isSlackConnected = await _isSlackConnected(user.uid);

      if (!isSlackConnected) {
        debugPrint(
          'RTDB MQTT event skipped: Slack integration is not connected.',
        );
        return;
      }

      final statusPreset = await _statusResolver.resolve(
        uid: user.uid,
        orientation: entry.orientation,
      );
      final resolvedEntry = entry.copyWith(
        cubeFace: statusPreset.cubeFace,
        slackEmojiCode: statusPreset.slackEmojiCode,
        statusId: statusPreset.id,
        statusLabel: statusPreset.label,
      );
      final eventReference = _eventsReference(user.uid).push();
      final eventId = eventReference.key;

      if (eventId == null) {
        debugPrint('RTDB MQTT event skipped: generated event id is empty.');
        return;
      }

      await eventReference.set(resolvedEntry.toRealtimeDatabaseMap());
      await _summaryReference(user.uid).runTransaction((currentData) {
        return Transaction.success(
          buildUpdatedMqttSummary(
            currentData: currentData,
            entry: resolvedEntry,
            eventId: eventId,
          ),
        );
      }, applyLocally: false);
    } on TelemetryStatusResolutionException catch (error) {
      debugPrint(error.message);
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

  Future<bool> _isSlackConnected(String uid) async {
    final snapshot = await _database
        .ref('users/$uid/integrations/slack/connected')
        .get();

    if (snapshot.value == true) {
      return true;
    }

    return _refreshSlackConnectionMarker();
  }

  Future<bool> _refreshSlackConnectionMarker() async {
    try {
      final result = await _functions
          .httpsCallable('getSlackConnectionStatus')
          .call<Object?>();
      final data = result.data;

      if (data is Map) {
        return data['connected'] == true;
      }
    } catch (error) {
      debugPrint('Slack connection refresh failed: $error');
    }

    return false;
  }
}
