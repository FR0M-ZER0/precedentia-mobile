import '../repositories/petition_text_repository.dart';

class SendPetitionTextUseCase {
  final PetitionTextRepository repository;

  SendPetitionTextUseCase(this.repository);

  Stream<Map<String, dynamic>> call({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
    required int userId,
  }) => repository.sendPetitionText(
    type: type,
    facts: facts,
    tribunal: tribunal,
    requests: requests,
    userId: userId,
  );
}
