import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  SecureStorageService._();

  static const String authTokenKey = 'auth_jwt_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> readToken() {
    return _storage.read(key: authTokenKey);
  }

  static Future<void> saveToken(String token) {
    return _storage.write(key: authTokenKey, value: token);
  }

  static Future<void> deleteToken() {
    return _storage.delete(key: authTokenKey);
  }

  static Future<int?> readUserId() async {
    final token = await readToken();
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final map = jsonDecode(payload) as Map<String, dynamic>;
    return map['id'] as int?;
  }
}
