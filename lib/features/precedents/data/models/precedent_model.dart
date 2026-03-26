import 'package:hive/hive.dart';
import '../../domain/precedent.dart';

part 'precedent_model.g.dart'; // Gerado pelo build_runner

@HiveType(typeId: 1)
class PrecedentModel extends Precedent {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String titulo;

  @override
  @HiveField(2)
  final String ementa;

  @HiveField(3)
  final DateTime dataAcesso; // Essa não precisa de @override pois só existe no Model

  // ... resto do construtor

  PrecedentModel({
    required this.id,
    required this.titulo,
    required this.ementa,
    required this.dataAcesso,
  }) : super(id: id, titulo: titulo, ementa: ementa);

  // Aqui ficariam os métodos fromJson (para o Dio)
}
