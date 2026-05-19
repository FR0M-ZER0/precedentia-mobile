import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/network/dio_client.dart';

abstract class PetitionRemoteDatasource {
  Future<Map<String, dynamic>> extractPetition(PlatformFile file);
}

class PetitionRemoteDatasourceImpl implements PetitionRemoteDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<Map<String, dynamic>> extractPetition(PlatformFile file) async {
    if (file.bytes == null) {
      throw Exception(
        'Os bytes do arquivo estão nulos. Verifique o FilePicker.',
      );
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });

    final response = await _dio.post(
      '/documents/extract',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.json,
      ),
    );
    return response.data as Map<String, dynamic>;
  }
}
