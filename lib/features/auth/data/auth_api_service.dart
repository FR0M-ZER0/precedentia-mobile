import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class AuthApiService {
  AuthApiService._();

  static final Dio _dio = DioClient.instance;

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  static Future<String> verifyTwoFactorCode({
    required String code,
    String? email,
  }) async {
    final response = await _dio.post(
      '/auth/verify',
      data: {
        'code': code,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      options: Options(contentType: Headers.jsonContentType),
    );

    final token = _extractToken(response.data);
    if (token == null || token.isEmpty) {
      throw const FormatException(
        'O JWT não foi retornado pela API de verificação.',
      );
    }

    return token;
  }

  static String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['token'],
        data['jwt'],
        data['accessToken'],
        data['access_token'],
        data['data'] is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>)['token']
            : null,
        data['data'] is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>)['jwt']
            : null,
        data['data'] is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>)['accessToken']
            : null,
        data['data'] is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>)['access_token']
            : null,
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }

    return null;
  }
}
