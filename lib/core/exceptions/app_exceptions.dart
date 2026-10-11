class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class RecentLoginRequiredException extends AuthException {
  const RecentLoginRequiredException()
    : super('Please confirm your identity before deleting your account.');
}

class StatusPresetException implements Exception {
  final String message;

  const StatusPresetException(this.message);

  @override
  String toString() => message;
}
