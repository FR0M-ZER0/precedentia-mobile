import 'package:hive/hive.dart';
import '../models/precedent_model.dart';

abstract class PrecedentsLocalDataSource {
  Future<void> saveAccessedPrecedent(PrecedentModel precedent);
  Future<List<PrecedentModel>> getAccessedPrecedents();
}

class PrecedentsLocalDataSourceImpl implements PrecedentsLocalDataSource {
  final Box<PrecedentModel> precedentBox;

  PrecedentsLocalDataSourceImpl({required this.precedentBox});

  @override
  Future<void> saveAccessedPrecedent(PrecedentModel precedent) async {
    // Usamos o ID do precedente como chave. 
    // Assim, se ele abrir o mesmo precedente duas vezes, apenas atualiza (não duplica no histórico).
    await precedentBox.put(precedent.id, precedent);
  }

  @override
  Future<List<PrecedentModel>> getAccessedPrecedents() async {
    // Pega todos os valores, transforma em lista e ordena do mais recente para o mais antigo
    final precedents = precedentBox.values.toList();
    precedents.sort((a, b) => b.dataAcesso.compareTo(a.dataAcesso));
    return precedents;
  }
}