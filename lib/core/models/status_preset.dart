import 'dart:convert';

class StatusPreset {
  final String id;
  final String label;
  final String iconKey;
  final bool isActive;

  const StatusPreset({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.isActive,
  });

  StatusPreset copyWith({
    String? id,
    String? label,
    String? iconKey,
    bool? isActive,
  }) {
    return StatusPreset(
      id: id ?? this.id,
      label: label ?? this.label,
      iconKey: iconKey ?? this.iconKey,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'label': label, 'iconKey': iconKey, 'isActive': isActive};
  }

  factory StatusPreset.fromMap(Map<String, dynamic> map) {
    return StatusPreset(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      iconKey: map['iconKey'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory StatusPreset.fromJson(String source) {
    return StatusPreset.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
