import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final returnedEmail = responseData['email'];
      if (returnedEmail is String && returnedEmail.isNotEmpty) {
        return returnedEmail;
      }
    }

    return email;
  }

  Future<String> verifyTwoFactor({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post(
      '/auth/verify',
      data: {'email': email, 'code': code},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final accessToken = responseData['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        return accessToken;
      }
    }

    throw Exception('Token de acesso não retornado pela API.');
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post(
      '/auth/password-reset/request',
      data: {'email': email},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post(
      '/auth/password-reset/confirm',
      data: {'email': email, 'code': code, 'new_password': newPassword},
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
  }
}
