import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_page.dart';
import 'package:kairo/features/mqtt/utils/cube_telemetry_database_parser.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';

class RealtimeTelemetryHistoryAuthException implements Exception {
  const RealtimeTelemetryHistoryAuthException();
}

class RealtimeTelemetryHistoryRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _database;

  RealtimeTelemetryHistoryRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseDatabase? database,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _database = database ?? createKairoRealtimeDatabase();

  Future<RealtimeTelemetryHistoryPage> fetchPage({
    required int limit,
    String? beforeKey,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      throw const RealtimeTelemetryHistoryAuthException();
    }

    final baseQuery = _eventsReference(uid).orderByKey();
    final Query pageQuery = beforeKey == null
        ? baseQuery.limitToLast(limit)
        : baseQuery.endBefore(beforeKey).limitToLast(limit);
    final snapshot = await pageQuery.get();
    final items = snapshot.children
        .where((child) => child.key != null)
        .map((child) {
          return RealtimeTelemetryHistoryItem(
            id: child.key!,
            entry: cubeTelemetryEntryFromDatabaseValue(child.value),
          );
        })
        .toList()
        .reversed
        .toList(growable: false);

    return RealtimeTelemetryHistoryPage(
      hasMore: items.length == limit,
      items: items,
    );
  }

  Stream<RealtimeTelemetryHistoryItem> watchLatestEvent() {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return Stream.error(const RealtimeTelemetryHistoryAuthException());
    }

    return _eventsReference(uid)
        .orderByKey()
        .limitToLast(1)
        .onChildAdded
        .where((event) => event.snapshot.key != null)
        .map((event) {
          return RealtimeTelemetryHistoryItem(
            id: event.snapshot.key!,
            entry: cubeTelemetryEntryFromDatabaseValue(event.snapshot.value),
          );
        });
  }

  DatabaseReference _eventsReference(String uid) {
    return _database.ref('users/$uid/mqtt_events');
  }
}
