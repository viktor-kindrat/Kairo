import 'dart:convert';

class LocalUser {
  final String fullName;
  final String email;
  final String password;
  final String roleTitle;
  final String? avatarPath;

  const LocalUser({
    required this.fullName,
    required this.email,
    required this.password,
    required this.roleTitle,
    this.avatarPath,
  });

  LocalUser copyWith({
    String? fullName,
    String? email,
    String? password,
    String? roleTitle,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return LocalUser(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      roleTitle: roleTitle ?? this.roleTitle,
      avatarPath: clearAvatarPath ? null : avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'roleTitle': roleTitle,
      'avatarPath': avatarPath,
    };
  }

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      roleTitle: map['roleTitle'] as String? ?? '',
      avatarPath: map['avatarPath'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LocalUser.fromJson(String source) {
    return LocalUser.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
