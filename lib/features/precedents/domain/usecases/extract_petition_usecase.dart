import '../repositories/petition_repository.dart';

class ExtractPetitionUseCase {
  final PetitionRepository repository;

  ExtractPetitionUseCase(this.repository);

  Future<Map<String, dynamic>> call(String filePath) {
    return repository.extractPetition(filePath);
  }
}