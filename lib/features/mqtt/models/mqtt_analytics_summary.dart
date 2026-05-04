class MqttAnalyticsSummary {
  final double averageBattery;
  final int? batteryMax;
  final int? batteryMin;
  final int batterySamples;
  final double batteryTotal;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;
  final String? latestEventId;
  final Map<String, int> orientationCounts;
  final Map<String, int> statusCounts;
  final int totalEvents;

  const MqttAnalyticsSummary({
    required this.averageBattery,
    required this.batterySamples,
    required this.batteryTotal,
    required this.orientationCounts,
    required this.statusCounts,
    required this.totalEvents,
    this.batteryMax,
    this.batteryMin,
    this.firstSeenAt,
    this.lastSeenAt,
    this.latestEventId,
  });

  factory MqttAnalyticsSummary.empty() {
    return const MqttAnalyticsSummary(
      averageBattery: 0,
      batterySamples: 0,
      batteryTotal: 0,
      orientationCounts: {},
      statusCounts: {},
      totalEvents: 0,
    );
  }

  factory MqttAnalyticsSummary.fromSnapshotValue(Object? value) {
    final data = _asMap(value);
    final batterySamples = _asInt(data['batterySamples']) ?? 0;
    final batteryTotal = _asDouble(data['batteryTotal']) ?? 0;
    final averageBattery =
        _asDouble(data['averageBattery']) ??
        (batterySamples == 0 ? 0 : batteryTotal / batterySamples);

    return MqttAnalyticsSummary(
      averageBattery: averageBattery,
      batteryMax: _asInt(data['batteryMax']),
      batteryMin: _asInt(data['batteryMin']),
      batterySamples: batterySamples,
      batteryTotal: batteryTotal,
      firstSeenAt: _asDateTime(data['firstSeenAt']),
      lastSeenAt: _asDateTime(data['lastSeenAt']),
      latestEventId: data['latestEventId'] as String?,
      orientationCounts: _asCounts(data['orientationCounts']),
      statusCounts: _asCounts(data['statusCounts']),
      totalEvents: _asInt(data['totalEvents']) ?? 0,
    );
  }

  bool get hasData => totalEvents > 0;

  String? get topOrientation => _topKey(orientationCounts);

  String? get topStatus => _topKey(statusCounts);

  static Map<String, Object?> _asMap(Object? value) {
    if (value is! Map) {
      return {};
    }

    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static Map<String, int> _asCounts(Object? value) {
    if (value is! Map) {
      return {};
    }

    final counts = <String, int>{};

    for (final entry in value.entries) {
      final key = entry.key?.toString() ?? '';
      final count = _asInt(entry.value) ?? 0;

      if (key.isNotEmpty && count > 0) {
        counts[key] = count;
      }
    }

    return counts;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static String? _topKey(Map<String, int> counts) {
    if (counts.isEmpty) {
      return null;
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.first.key;
  }
}
