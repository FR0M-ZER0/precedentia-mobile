import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
}