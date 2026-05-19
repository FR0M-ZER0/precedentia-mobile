import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  static const String _tokenKey = 'precedentia_access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  Future<bool> initialize() async {
    final token = await _storage.read(key: _tokenKey);
    final isAuthenticated = token != null && token.isNotEmpty;
    authNotifier.value = isAuthenticated;
    return isAuthenticated;
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    authNotifier.value = true;
  }

  Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    authNotifier.value = false;
  }
}
