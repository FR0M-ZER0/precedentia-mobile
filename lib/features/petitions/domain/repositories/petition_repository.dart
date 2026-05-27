import 'package:file_picker/file_picker.dart';

abstract class PetitionRepository {
  Stream<Map<String, dynamic>> extractPetition(PlatformFile file, int userId);
}
