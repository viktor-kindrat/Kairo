import 'dart:convert';

import 'package:kairo/core/models/local_user.dart';

class PendingEmailVerification {
  final LocalUser user;
  final String code;

  const PendingEmailVerification({required this.user, required this.code});

  PendingEmailVerification copyWith({LocalUser? user, String? code}) {
    return PendingEmailVerification(
      user: user ?? this.user,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toMap() {
    return {'user': user.toMap(), 'code': code};
  }

  factory PendingEmailVerification.fromMap(Map<String, dynamic> map) {
    return PendingEmailVerification(
      user: LocalUser.fromMap(map['user'] as Map<String, dynamic>),
      code: map['code'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PendingEmailVerification.fromJson(String source) {
    return PendingEmailVerification.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}
