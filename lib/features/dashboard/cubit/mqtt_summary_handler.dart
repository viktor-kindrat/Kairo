import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:kairo/features/mqtt/models/mqtt_analytics_summary.dart';
import 'package:kairo/features/mqtt/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

typedef SummaryCallback = void Function(MqttAnalyticsSummary? summary);
typedef ConnectionCallback = void Function(MqttConnectionState state);
typedef TopicCallback = void Function(String? topic);

class MqttSummaryHandler {
  final FirebaseDatabase _database;
  final SummaryCallback _onSummary;
  final ConnectionCallback _onConnection;
  final TopicCallback _onTopic;

  StreamSubscription<DatabaseEvent>? _sub;
  late final VoidCallback _connectionListener;
  late final VoidCallback _topicListener;

  MqttSummaryHandler({
    required FirebaseDatabase database,
    required SummaryCallback onSummary,
    required ConnectionCallback onConnection,
    required TopicCallback onTopic,
  })  : _database = database,
        _onSummary = onSummary,
        _onConnection = onConnection,
        _onTopic = onTopic {
    _connectionListener =
        () => _onConnection(MqttService.instance.connectionState.value);
    _topicListener =
        () => _onTopic(MqttService.instance.subscribedTopic.value);
    MqttService.instance.connectionState.addListener(_connectionListener);
    MqttService.instance.subscribedTopic.addListener(_topicListener);
  }

  void startSummaryStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    unawaited(_sub?.cancel());
    _sub = _database
        .ref('users/$uid/mqtt_analytics/summary')
        .onValue
        .listen((event) {
      _onSummary(
        MqttAnalyticsSummary.fromSnapshotValue(event.snapshot.value),
      );
    });
  }

  Future<void> dispose() async {
    MqttService.instance.connectionState.removeListener(_connectionListener);
    MqttService.instance.subscribedTopic.removeListener(_topicListener);
    await _sub?.cancel();
    _sub = null;
  }
}
