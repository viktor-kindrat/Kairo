import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kairo/features/mqtt/models/realtime_telemetry_history_item.dart';
import 'package:kairo/features/mqtt/utils/cube_telemetry_database_parser.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';

class HomeActivityAuthException implements Exception {
  const HomeActivityAuthException();
}

class HomeActivityEvents {
  final RealtimeTelemetryHistoryItem? carryInEvent;
  final RealtimeTelemetryHistoryItem? latestEvent;
  final List<RealtimeTelemetryHistoryItem> todayEvents;

  const HomeActivityEvents({
    required this.todayEvents,
    this.carryInEvent,
    this.latestEvent,
  });
}

class HomeActivityRepository {
  static const int _activityFetchLimit = 1000;

  final FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _database;

  HomeActivityRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseDatabase? database,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _database = database ?? createKairoRealtimeDatabase();

  Future<HomeActivityEvents> fetchTodayEvents(DateTime dayStart) async {
    final uid = _uid;
    final snapshot = await _eventsReference(
      uid,
    ).orderByKey().limitToLast(_activityFetchLimit).get();
    final events = _itemsFromSnapshot(snapshot);
    final todayEvents = events
        .where((event) {
          return !event.entry.receivedAt.toLocal().isBefore(dayStart);
        })
        .toList(growable: false);
    final carryInEvents = events
        .where((event) {
          return event.entry.receivedAt.toLocal().isBefore(dayStart);
        })
        .toList(growable: false);

    return HomeActivityEvents(
      carryInEvent: carryInEvents.isEmpty ? null : carryInEvents.last,
      latestEvent: events.isEmpty ? null : events.last,
      todayEvents: todayEvents,
    );
  }

  Stream<RealtimeTelemetryHistoryItem> watchTodayEvents(DateTime dayStart) {
    return _eventsReference(_uid)
        .orderByKey()
        .limitToLast(1)
        .onChildAdded
        .where((event) => event.snapshot.key != null)
        .map((event) {
          return RealtimeTelemetryHistoryItem(
            id: event.snapshot.key!,
            entry: cubeTelemetryEntryFromDatabaseValue(event.snapshot.value),
          );
        })
        .where((event) {
          return !event.entry.receivedAt.toLocal().isBefore(dayStart);
        });
  }

  String get _uid {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      throw const HomeActivityAuthException();
    }

    return uid;
  }

  DatabaseReference _eventsReference(String uid) {
    return _database.ref('users/$uid/mqtt_events');
  }

  List<RealtimeTelemetryHistoryItem> _itemsFromSnapshot(DataSnapshot snapshot) {
    final items = snapshot.children.where((child) => child.key != null).map((
      child,
    ) {
      return RealtimeTelemetryHistoryItem(
        id: child.key!,
        entry: cubeTelemetryEntryFromDatabaseValue(child.value),
      );
    }).toList();

    items.sort((a, b) => a.entry.receivedAt.compareTo(b.entry.receivedAt));
    return items;
  }
}
