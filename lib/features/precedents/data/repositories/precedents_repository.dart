import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/precedent.dart';

abstract class PrecedentsRepository {
  // Contrato para buscar um precedente específico (da API ou do Hive)
  Future<Either<Failure, Precedent>> getPrecedentDetails(String id);

  // Contrato para buscar o histórico de precedentes (do Hive)
  Future<Either<Failure, List<Precedent>>> getHistory();
}