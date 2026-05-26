import 'package:file_picker/file_picker.dart';
import '../../domain/repositories/petition_repository.dart';
import '../../../precedents/data/datasource/petition_remote_datasource.dart';

class PetitionFileRepositoryImpl implements PetitionRepository {
  final PetitionRemoteDatasource datasource;

  PetitionFileRepositoryImpl(this.datasource);

  @override
  Future<Map<String, dynamic>> extractPetition(PlatformFile file) {
    return datasource.extractPetition(file);
  }
}
