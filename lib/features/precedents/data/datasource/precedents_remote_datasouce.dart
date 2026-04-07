import 'package:dio/dio.dart';
import '../models/precedent_model.dart';

//Fiz isso com algumas boas recomendações do gemini qualquer coisa me mande
//uma mensagem

// 1. O Contrato: Define O QUE essa fonte de dados deve fazer
abstract class PrecedentsRemoteDataSource {
  Future<PrecedentModel> fetchPrecedent(String id);
}

// 2. A Implementação: Define COMO vai fazer (usando o Dio)
class PrecedentsRemoteDataSourceImpl implements PrecedentsRemoteDataSource {
  final Dio dio;

  PrecedentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<PrecedentModel> fetchPrecedent(String id) async {
    try {
      // Faz a requisição HTTP para a sua API real
      final response = await dio.get('URL_DA_SUA_API/precedentes/$id');

      if (response.statusCode == 200) {
        // Aqui você vai converter o JSON da API para o seu PrecedentModel
        // Exemplo: return PrecedentModel.fromJson(response.data);

        // Temporário até termos o fromJson no modelo:
        throw UnimplementedError(
          'Precisamos criar o fromJson no PrecedentModel',
        );
      } else {
        // Lança uma exceção que será capturada pelo Repositório
        throw Exception('Erro no servidor');
      }
    } catch (e) {
      throw Exception('Erro de conexão ou servidor: $e');
    }
  }
}
