import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/sentence_repository.dart';
import '../datasource/sentence_remote_datasource.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final SentenceRemoteDatasource datasource;

  SentenceRepositoryImpl(this.datasource);

  @override
  Stream<Map<String, dynamic>> extractSentenceStream(
    PlatformFile file,
    int userId,
  ) {
    return datasource.extractSentenceStream(file, userId);
  }
}
