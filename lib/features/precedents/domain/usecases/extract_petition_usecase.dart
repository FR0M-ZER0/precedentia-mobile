import 'package:file_picker/file_picker.dart';
import 'package:precedentia_mobile/features/precedents/domain/repositories/petition_repository.dart';
// Importe o seu repository e entidades aqui...

class ExtractPetitionUseCase {
  final PetitionRepository repository;

  ExtractPetitionUseCase(this.repository);

  // MUDANÇA AQUI: Alterado de String para PlatformFile
  Future<dynamic> call(PlatformFile file) async {
    return await repository.extractPetition(file);
  }
}