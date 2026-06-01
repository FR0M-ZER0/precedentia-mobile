import 'package:file_picker/file_picker.dart';
import '../repositories/sentence_repository.dart';

class ExtractSentenceUseCase {
  final SentenceRepository repository;

  ExtractSentenceUseCase(this.repository);

  Stream<Map<String, dynamic>> call(PlatformFile file, int userId) {
    return repository.extractSentenceStream(file, userId);
  }
}
