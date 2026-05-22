import 'package:dio/dio.dart';

class DioClient {
  DioClient._();
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8087',
  );

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: _apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 2),
      headers: {'Content-Type': 'multipart/form-data'},
    ),
  );
}
