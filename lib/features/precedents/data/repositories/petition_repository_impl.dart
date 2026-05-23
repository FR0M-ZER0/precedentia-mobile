import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/petition_repository.dart';
import '../datasource/petition_remote_datasource.dart';

class PetitionRepositoryImpl implements PetitionRepository {
  final PetitionRemoteDatasource datasource;

  PetitionRepositoryImpl(this.datasource);

  @override
  Future<Map<String, dynamic>> extractPetition(PlatformFile file, int userId) {
    return datasource.extractPetition(file, userId);
  }
}
