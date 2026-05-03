import 'dart:convert';

class StatusPreset {
  final String cubeFace;
  final String id;
  final bool isActive;
  final String label;
  final String slackEmojiCode;
  final int sortOrder;

  const StatusPreset({
    required this.cubeFace,
    required this.id,
    required this.isActive,
    required this.label,
    required this.slackEmojiCode,
    required this.sortOrder,
  });

  StatusPreset copyWith({
    String? cubeFace,
    String? id,
    bool? isActive,
    String? label,
    String? slackEmojiCode,
    int? sortOrder,
  }) {
    return StatusPreset(
      cubeFace: cubeFace ?? this.cubeFace,
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      slackEmojiCode: slackEmojiCode ?? this.slackEmojiCode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cubeFace': cubeFace,
      'id': id,
      'isActive': isActive,
      'label': label,
      'slackEmojiCode': slackEmojiCode,
      'sortOrder': sortOrder,
    };
  }

  factory StatusPreset.fromMap(Map<String, dynamic> map) {
    return StatusPreset(
      cubeFace: map['cubeFace'] as String? ?? '',
      id: map['id'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? false,
      label: map['label'] as String? ?? '',
      slackEmojiCode: map['slackEmojiCode'] as String? ?? '',
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory StatusPreset.fromJson(String source) {
    return StatusPreset.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
