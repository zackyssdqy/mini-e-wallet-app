import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage(this._sharedPreferences);

  static const _tokenKey = 'auth_token';

  final SharedPreferences _sharedPreferences;

  Future<String?> readToken() async {
    return _sharedPreferences.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    await _sharedPreferences.remove(_tokenKey);
  }
}
