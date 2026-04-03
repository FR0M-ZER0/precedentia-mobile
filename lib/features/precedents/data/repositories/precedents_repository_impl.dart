import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/precedent.dart';
import '../repositories/precedents_repository.dart';
import '../datasource/precedents_local_datasource.dart';
import '../datasource/precedents_remote_datasouce.dart';

class PrecedentsRepositoryImpl implements PrecedentsRepository {
  final PrecedentsRemoteDataSource remoteDataSource; // Usa o Dio
  final PrecedentsLocalDataSource localDataSource; // Usa o Hive

  PrecedentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // Função chamada quando o usuário busca um precedente específico
  @override
  Future<Either<Failure, Precedent>> getPrecedentDetails(String id) async {
    try {
      // 1. Busca os detalhes completões na API (Dio)
      final precedentModel = await remoteDataSource.fetchPrecedent(id);

      // 2. Salva no Hive para o histórico de acessos (silenciosamente)
      await localDataSource.saveAccessedPrecedent(precedentModel);

      return Right(precedentModel.toDomain());
    } catch (e) {
      // Se falhar (ex: sem internet), tenta buscar do Hive! (Acesso Offline)
      final localPrecedents = await localDataSource.getAccessedPrecedents();
      final offlinePrecedent = localPrecedents
          .where((p) => p.id == id)
          .firstOrNull;

      if (offlinePrecedent != null) {
        return Right(offlinePrecedent.toDomain());
      }
      return Left(ServerFailure());
    }
  }

  // Função chamada pela tela de "Histórico"
  @override
  Future<Either<Failure, List<Precedent>>> getHistory() async {
    try {
      final history = await localDataSource.getAccessedPrecedents();
      return Right(history.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
