import 'package:file_picker/file_picker.dart';

import '../repositories/petition_text_repository.dart';

class SendPetitionTextUseCase {
  final PetitionTextRepository repository;

  SendPetitionTextUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String type,
    required String authorDescription,
    required String defendantDescription,
    required String facts,
    PlatformFile? factsFile,
    required String tribunal,
    required List<String> requests,
    required String causeValue,
    required bool hasUrgencyTutela,
    required bool hasFreeJustice,
  }) {
    return repository.sendPetitionText(
      type: type,
      authorDescription: authorDescription,
      defendantDescription: defendantDescription,
      facts: facts,
      factsFile: factsFile,
      tribunal: tribunal,
      requests: requests,
      causeValue: causeValue,
      hasUrgencyTutela: hasUrgencyTutela,
      hasFreeJustice: hasFreeJustice,
    );
  }
}
