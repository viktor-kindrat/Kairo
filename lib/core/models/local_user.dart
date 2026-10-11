import 'dart:convert';

class LocalUser {
  final String fullName;
  final String email;
  final String password;
  final String roleTitle;
  final String? avatarUrl;

  const LocalUser({
    required this.fullName,
    required this.email,
    required this.password,
    required this.roleTitle,
    this.avatarUrl,
  });

  LocalUser copyWith({
    String? fullName,
    String? email,
    String? password,
    String? roleTitle,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return LocalUser(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      roleTitle: roleTitle ?? this.roleTitle,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'roleTitle': roleTitle,
      'avatarUrl': avatarUrl,
    };
  }

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    final avatarUrl = map['avatarUrl'] ?? map['avatarPath'];

    return LocalUser(
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      roleTitle: map['roleTitle'] as String? ?? '',
      avatarUrl: avatarUrl as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LocalUser.fromJson(String source) {
    return LocalUser.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
