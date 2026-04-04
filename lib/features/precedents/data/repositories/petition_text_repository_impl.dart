import '../../domain/repositories/petition_text_repository.dart';
import '../datasource/petition_text_remote_datasource.dart';

class PetitionRepositoryImpl implements PetitionTextRepository {
  final PetitionRemoteDatasource datasource;
  PetitionRepositoryImpl(this.datasource);

  @override
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  }) => datasource.sendPetitionText(
        type: type,
        facts: facts,
        tribunal: tribunal,
        requests: requests,
      );
}