import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:kairo/features/dashboard/widgets/mqtt_analytics_summary_content.dart';
import 'package:kairo/features/dashboard/widgets/realtime_analytics_message_card.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';
import 'package:kairo/features/mqtt/utils/kairo_realtime_database.dart';

class RealtimeDatabaseAnalyticsCard extends StatelessWidget {
  final FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _database;

  RealtimeDatabaseAnalyticsCard({
    FirebaseAuth? firebaseAuth,
    FirebaseDatabase? database,
    super.key,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _database = database ?? createKairoRealtimeDatabase();

  @override
  Widget build(BuildContext context) {
    final uid = _firebaseAuth.currentUser?.uid;

    if (uid == null) {
      return const RealtimeAnalyticsMessageCard(
        message: 'Sign in to sync MQTT analytics.',
      );
    }

    return StreamBuilder<DatabaseEvent>(
      stream: _summaryReference(uid).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const RealtimeAnalyticsMessageCard(
            message: 'Could not load saved MQTT analytics.',
          );
        }

        if (!snapshot.hasData) {
          return const RealtimeAnalyticsMessageCard(
            leading: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            message: 'Loading saved MQTT analytics...',
          );
        }

        final summary = MqttAnalyticsSummary.fromSnapshotValue(
          snapshot.data?.snapshot.value,
        );

        if (!summary.hasData) {
          return const RealtimeAnalyticsMessageCard(
            message: 'No saved MQTT analytics yet.',
          );
        }

        return MqttAnalyticsSummaryContent(summary: summary);
      },
    );
  }

  DatabaseReference _summaryReference(String uid) {
    return _database.ref('users/$uid/mqtt_analytics/summary');
  }
}
