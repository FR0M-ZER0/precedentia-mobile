import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:precedentia_mobile/core/network/dio_client.dart';

abstract class PetitionRemoteDatasource {
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  });
}

class PetitionRemoteDatasourceImpl implements PetitionRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  }) async {
    final response = await _dio.post(
      '/analysis/send-petition',
      data: {
        'type': type,
        'facts': facts,
        'tribunal': tribunal,
        'requests': requests,
      },
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 2),
      ),
    );

    if (response.data is String) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    }

    return response.data as Map<String, dynamic>;
  }
}
