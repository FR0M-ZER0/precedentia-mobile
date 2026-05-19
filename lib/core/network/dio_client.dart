import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8087',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 2),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
