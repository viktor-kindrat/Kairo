class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class StatusPresetException implements Exception {
  final String message;

  const StatusPresetException(this.message);

  @override
  String toString() => message;
}
