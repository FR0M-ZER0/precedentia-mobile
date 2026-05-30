import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  DioClient._();
  static final String precedentiaApiUrl =
      dotenv.env['PRECEDENTIA_API_URL'] ?? '';

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: precedentiaApiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 2),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
