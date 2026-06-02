import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:precedentia_mobile/core/network/dio_client.dart';

abstract class PetitionRemoteDatasource {
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String authorDescription,
    required String defendantDescription,
    required String facts,
    PlatformFile? factsFile,
    required String tribunal,
    required List<String> requests,
    required String causeValue,
    required bool hasUrgencyTutela,
    required bool hasFreeJustice,
  });
}

class PetitionRemoteDatasourceImpl implements PetitionRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String authorDescription,
    required String defendantDescription,
    required String facts,
    PlatformFile? factsFile,
    required String tribunal,
    required List<String> requests,
    required String causeValue,
    required bool hasUrgencyTutela,
    required bool hasFreeJustice,
  }) async {
    final data = FormData.fromMap({
      'type': type,
      'authorDescription': authorDescription,
      'defendantDescription': defendantDescription,
      'facts': facts,
      'tribunal': tribunal,
      'requests': jsonEncode(requests),
      'causeValue': causeValue,
      'hasUrgencyTutela': hasUrgencyTutela,
      'hasFreeJustice': hasFreeJustice,
      if (factsFile != null)
        'factsFile': MultipartFile.fromBytes(
          factsFile.bytes!,
          filename: factsFile.name,
        ),
    });

    final response = await _dio.post(
      '/analysis/send-petition',
      data: data,
      options: Options(
        contentType: 'multipart/form-data',
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
