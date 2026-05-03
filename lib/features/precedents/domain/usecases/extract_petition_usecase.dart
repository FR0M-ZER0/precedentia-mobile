import 'package:file_picker/file_picker.dart';
import '../repositories/petition_repository.dart';

class ExtractPetitionUseCase {
  final PetitionRepository repository;

  ExtractPetitionUseCase(this.repository);

  Future<dynamic> call(PlatformFile file) async {
    return await repository.extractPetition(file);
  }
}
