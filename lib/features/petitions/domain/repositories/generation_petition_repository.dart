import 'package:file_picker/file_picker.dart';

abstract class GenerationPetitionRepository {
  Future<Map<String, dynamic>> generatePetition({
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
  });
}
