import 'package:kairo/core/constants.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserStore {
  final SharedPreferences _preferences;

  const LocalUserStore(this._preferences);

  Future<void> clearSessionEmail() async {
    await _preferences.remove(authSessionKey);
  }

  Future<void> clearUser() async {
    await _preferences.remove(storedUserKey);
  }

  String? readSessionEmail() => _preferences.getString(authSessionKey);

  LocalUser? readUser() {
    final storedUser = _preferences.getString(storedUserKey);

    if (storedUser == null) {
      return null;
    }

    return LocalUser.fromJson(storedUser);
  }

  Future<void> writeSessionEmail(String email) async {
    await _preferences.setString(authSessionKey, email);
  }

  Future<void> writeUser(LocalUser user) async {
    await _preferences.setString(storedUserKey, user.toJson());
  }

  Future<void> writeUserAndSession(LocalUser user) async {
    await writeUser(user);
    await writeSessionEmail(user.email);
  }
}
