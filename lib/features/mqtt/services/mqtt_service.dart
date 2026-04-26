import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:kairo/features/mqtt/models/cube_telemetry_entry.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String defaultTopic = 'kairo/cube/orientation';
  static const int historyLimit = 50;

  static final MqttService instance = MqttService._();

  final ValueNotifier<String> latestMessage = ValueNotifier<String>(
    'No MQTT data received yet.',
  );
  final ValueNotifier<CubeTelemetryEntry?> latestTelemetry =
      ValueNotifier<CubeTelemetryEntry?>(null);
  final ValueNotifier<List<CubeTelemetryEntry>> telemetryHistory =
      ValueNotifier<List<CubeTelemetryEntry>>(const []);
  final ValueNotifier<MqttConnectionState> connectionState =
      ValueNotifier<MqttConnectionState>(MqttConnectionState.disconnected);

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>?>? _updatesSub;

  MqttService._();

  Future<void> connect() async {
    if (connectionState.value == MqttConnectionState.connected) {
      return;
    }

    await disconnect();
    connectionState.value = MqttConnectionState.connecting;

    final client = MqttServerClient.withPort(
      'broker.hivemq.com',
      'kairo_flutter_client_${Random().nextInt(1000)}',
      1883,
    );

    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;
    client.onConnected = _handleConnected;
    client.onDisconnected = _handleDisconnected;
    client.onAutoReconnect = _handleAutoReconnect;
    client.onAutoReconnected = _handleConnected;
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client = client;

    try {
      await client.connect();

      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        connectionState.value =
            client.connectionStatus?.state ?? MqttConnectionState.faulted;
        debugPrint('MQTT connection failed: ${client.connectionStatus?.state}');
        client.disconnect();
        return;
      }

      _listenForMessages(client);
    } catch (error, stackTrace) {
      connectionState.value = MqttConnectionState.faulted;
      debugPrint('MQTT connect error: $error');
      debugPrintStack(stackTrace: stackTrace);
      client.disconnect();
    }
  }

  Future<void> disconnect() async {
    await _updatesSub?.cancel();
    _updatesSub = null;

    final client = _client;
    _client = null;

    if (client != null) {
      client.disconnect();
    } else {
      connectionState.value = MqttConnectionState.disconnected;
    }
  }

  void subscribe(String topic) {
    final client = _client;

    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('MQTT subscribe skipped: client is not connected.');
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void _handleAutoReconnect() {
    connectionState.value = MqttConnectionState.connecting;
  }

  void _handleConnected() {
    connectionState.value = MqttConnectionState.connected;
  }

  void _handleDisconnected() {
    if (connectionState.value != MqttConnectionState.faulted) {
      connectionState.value = MqttConnectionState.disconnected;
    }
  }

  void _listenForMessages(MqttServerClient client) {
    _updatesSub?.cancel();
    _updatesSub = client.updates?.listen((messages) {
      if (messages.isEmpty) {
        return;
      }

      final payload = messages.first.payload as MqttPublishMessage;
      final rawMessage = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );
      final telemetryEntry = CubeTelemetryEntry.fromPayload(rawMessage);

      latestMessage.value = rawMessage;
      latestTelemetry.value = telemetryEntry;
      telemetryHistory.value = [
        telemetryEntry,
        ...telemetryHistory.value,
      ].take(historyLimit).toList(growable: false);
    });
  }
}
