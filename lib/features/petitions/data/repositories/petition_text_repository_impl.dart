import 'package:file_picker/file_picker.dart';

import '../../domain/repositories/petition_text_repository.dart';
import '../datasource/petition_text_remote_datasource.dart';

class PetitionTextRepositoryImpl implements PetitionTextRepository {
  final PetitionRemoteDatasource datasource;

  PetitionTextRepositoryImpl(this.datasource);

  @override
  Future<Map<String, dynamic>> sendPetitionText({
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
    return datasource.sendPetitionText(
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
