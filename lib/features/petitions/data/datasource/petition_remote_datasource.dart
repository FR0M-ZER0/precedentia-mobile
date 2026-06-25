import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importe do pacote dotenv
import 'package:flutter/foundation.dart' show kIsWeb; // Importe para verificar se é Web
import 'package:http/http.dart' as http; // Importe do http para o upload multipart
import '../models/petition_model.dart';
import 'package:file_picker/file_picker.dart'; // Assumindo que usa file_picker para selecionar o ficheiro

// 1. O Contrato: Define O QUE esta fonte de dados deve fazer
abstract class PetitionsRemoteDataSource {
  Future<PetitionModel> fetchPetition(String id);
  Future<bool> uploadPetitionFile(PlatformFile pickedFile); // Adicionei o método de upload no contrato
}

// 2. A Implementação: Define COMO vai fazer (usando o Dio e http)
class PetitionsRemoteDataSourceImpl implements PetitionsRemoteDataSource {
  final Dio dio;

  PetitionsRemoteDataSourceImpl({required this.dio});

  // --- Método 1: GET - Buscar uma petição pelo ID ---
  @override
  Future<PetitionModel> fetchPetition(String id) async {
    try {
      // 1. Puxa a URL base do .env (com um fallback de segurança caso falhe)
      final baseUrl = dotenv.env['PRECEDENTIA_API_URL'] ?? 'http://168.138.158.39:32373';
      
      // Faz a requisição HTTP montando a URL completa
      final response = await dio.get('$baseUrl/precedentes/$id');

      if (response.statusCode == 200) {
        // Aqui vais converter o JSON da API para o teu PetitionModel
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

  // --- Método 2: POST - Fazer o Upload do Ficheiro PDF/DOCX ---
  @override
  Future<bool> uploadPetitionFile(PlatformFile pickedFile) async {
    try {
       // Puxa a URL base do .env (com o mesmo fallback)
      final baseUrl = dotenv.env['PRECEDENTIA_API_URL'] ?? 'http://168.138.158.39:32373';
      var uri = Uri.parse('$baseUrl/documents/extract');
      
      var request = http.MultipartRequest('POST', uri);

      // ✅ A LÓGICA CRUCIAL PARA A WEB FUNCIONAR
      if (kIsWeb) {
        // Para a Web (Navegador): Usa os bytes diretamente da memória
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            pickedFile.bytes!, // <-- Pega os bytes da memória
            filename: pickedFile.name,
          ),
        );
      } else {
        // Para Mobile (Android/iOS): Usa o path (caminho no disco)
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            pickedFile.path!,
          ),
        );
      }

      // Envia a requisição
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
          print('Upload realizado com sucesso!');
          return true;
      } else {
          print('Erro no upload. Status: ${response.statusCode}');
          return false;
      }

    } catch (e) {
      print('Erro ao enviar o ficheiro: $e');
      return false;
    }
  }
}
