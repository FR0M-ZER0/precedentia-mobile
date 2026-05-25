import 'package:file_picker/file_picker.dart';

abstract class PetitionTextRepository {
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
  });
}
