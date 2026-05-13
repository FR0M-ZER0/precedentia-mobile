import 'package:file_picker/file_picker.dart';

abstract class PetitionRepository {
  Future<Map<String, dynamic>> extractPetition(PlatformFile file);
}
