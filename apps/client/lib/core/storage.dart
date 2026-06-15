import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:client/models/user.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveUser(User user) =>
      _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

  static Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw));
  }

  static Future<void> clear() => _storage.deleteAll();
}
