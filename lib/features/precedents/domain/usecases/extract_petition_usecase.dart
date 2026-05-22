import 'package:file_picker/file_picker.dart';
import '../repositories/petition_repository.dart';

class ExtractPetitionUseCase {
  final PetitionRepository repository;

  ExtractPetitionUseCase(this.repository);

  Future<Map<String, dynamic>> call(PlatformFile file, int userId) async {
    return await repository.extractPetition(file, userId);
  }
}
