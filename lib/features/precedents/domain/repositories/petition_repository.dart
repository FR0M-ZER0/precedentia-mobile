abstract class PetitionRepository {
  Future<Map<String, dynamic>> extractPetition(String filePath);
}