import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importe o pacote dotenv
import '../models/petition_model.dart';

// 1. O Contrato: Define O QUE essa fonte de dados deve fazer
abstract class PetitionsRemoteDataSource {
  Future<PetitionModel> fetchPetition(String id);
}

// 2. A Implementação: Define COMO vai fazer (usando o Dio)
class PetitionsRemoteDataSourceImpl implements PetitionsRemoteDataSource {
  final Dio dio;

  PetitionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PetitionModel> fetchPetition(String id) async {
    try {
      // 1. Puxa a URL base do .env (com um fallback de segurança caso falhe)
      final baseUrl = dotenv.env['PRECEDENTIA_API_URL'] ?? 'http://168.138.158.39:32373';
      
      // Faz a requisição HTTP montando a URL completa
      final response = await dio.get('$baseUrl/precedentes/$id');

      if (response.statusCode == 200) {
        // Aqui você vai converter o JSON da API para o seu PetitionModel
        // Exemplo: return PetitionModel.fromJson(response.data);

        // Temporário até termos o fromJson no modelo:
        throw UnimplementedError(
          'Precisamos criar o fromJson no PetitionModel',
        );
      } else {
        // Lança uma exceção que será capturada pelo Repositório
        throw Exception('Erro no servidor. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão ou servidor: $e');
    }
  }
}
