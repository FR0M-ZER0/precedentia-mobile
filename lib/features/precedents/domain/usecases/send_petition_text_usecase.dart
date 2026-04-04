import '../repositories/petition_text_repository.dart';

class SendPetitionTextUseCase {
  final PetitionTextRepository repository;

  SendPetitionTextUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  }) => repository.sendPetitionText(
        type: type,
        facts: facts,
        tribunal: tribunal,
        requests: requests,
      );
}