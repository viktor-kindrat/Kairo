import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

const kairoRealtimeDatabaseUrl = String.fromEnvironment(
  'FIREBASE_DATABASE_URL',
  defaultValue: 'https://kairo-status-hub-default-rtdb.firebaseio.com',
);

FirebaseDatabase createKairoRealtimeDatabase() {
  return FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: kairoRealtimeDatabaseUrl,
  );
}
