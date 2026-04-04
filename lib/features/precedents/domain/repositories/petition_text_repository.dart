abstract class PetitionTextRepository {
  Future<Map<String, dynamic>> sendPetitionText({
    required String type,
    required String facts,
    required String tribunal,
    required List<String> requests,
  });
}