import 'package:file_picker/file_picker.dart';

import '../repositories/generation_petition_repository.dart';

class GeneratePetitionUseCase {
  final GenerationPetitionRepository repository;

  GeneratePetitionUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String authorDescription,
    required String defendantDescription,
    required String actionType,
    required String tribunal,
    required String factsSummary,
    required List<String> requests,
    required String valueOfCause,
    required bool urgentRelief,
    required bool freeJustice,
    required List<PlatformFile> pdfs,
  }) {
    return repository.generatePetition(
      authorDescription: authorDescription,
      defendantDescription: defendantDescription,
      actionType: actionType,
      tribunal: tribunal,
      factsSummary: factsSummary,
      requests: requests,
      valueOfCause: valueOfCause,
      urgentRelief: urgentRelief,
      freeJustice: freeJustice,
      pdfs: pdfs,
    );
  }
}
