import '../../../../core/network/dio_client.dart';
import '../models/analysis_model.dart';

class AnalysisApiService {
  AnalysisApiService._();

  static Future<List<AnalysisModel>> getSearches() async {
    final response = await DioClient.instance.get('/analysis/searches');

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => AnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
