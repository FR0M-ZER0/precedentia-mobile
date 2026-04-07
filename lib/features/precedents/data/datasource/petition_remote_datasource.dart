import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

abstract class PetitionRemoteDatasource {
  Future<Map<String, dynamic>> extractPetition(String filePath);
}

class PetitionRemoteDatasourceImpl implements PetitionRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> extractPetition(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _dio.post('/documents/extract', data: formData);

    return response.data as Map<String, dynamic>;
  }
}
